#!/usr/bin/env bash

# Setup vault enterprise as server
set -e

# USER VARS
NODE_NAME="${1:-$(hostname -s)}"
VAULT_VERSION="1.7.3"
VAULT_DIR=/usr/local/bin
VAULT_CONFIG_DIR=/etc/vault.d
VAULT_DATA_DIR=/opt/vault

# CALCULATED VARS
VAULT_PATH=${VAULT_DIR}/vault
VAULT_ZIP="vault_${VAULT_VERSION}+ent.hsm_linux_amd64.zip"
VAULT_URL="https://releases.hashicorp.com/vault/${VAULT_VERSION}+ent.hsm/${VAULT_ZIP}"



# CHECK DEPENDANCIES AND SET NET RETRIEVAL TOOL
if ! unzip -h 2&> /dev/null; then
  echo "aborting - unzip not installed and required"
  exit 1
fi
if curl -h 2&> /dev/null; then
  nettool="curl"
elif wget -h 2&> /dev/null; then
  nettool="wget"
else
  echo "aborting - neither wget nor curl installed and required"
  exit 1
fi

set +e
# try to get private IP
pri_ip=$(hostname -I 2> /dev/null | awk '{print $1}')
set -e

# download and extract binary
echo "Downloading and installing vault ${VAULT_VERSION}"
case "${nettool}" in
  wget)
    wget --no-check-certificate "${VAULT_URL}" --output-document="${VAULT_ZIP}"
    ;;
  curl)
    [ 200 -ne $(curl --write-out %{http_code} --silent --output ${VAULT_ZIP} ${VAULT_URL}) ] && exit 1
    ;;
esac

unzip "${VAULT_ZIP}"
sudo mv vault "$VAULT_DIR"
sudo chmod 0755 "${VAULT_PATH}"
sudo chown root:root "${VAULT_PATH}"


echo "Version Installed: $(vault --version)"
vault -autocomplete-install
complete -C "${VAULT_PATH}" vault
sudo setcap cap_ipc_lock=+ep "${VAULT_PATH}"


echo "Creating Vault user and directories"
sudo mkdir --parents "${VAULT_CONFIG_DIR}"
sudo useradd --system --home "${VAULT_CONFIG_DIR}" --shell /bin/false vault
sudo mkdir --parents "${VAULT_DATA_DIR}"
sudo chown --recursive vault:vault "${VAULT_DATA_DIR}"

echo "Creating directory for Oracle DB plugin"
sudo mkdir -pm 0755 /data/vault/plugins
sudo chown -R vault:vault /data/vault/plugins


echo "Creating vault config for ${VAULT_VERSION}"
sudo tee "${VAULT_CONFIG_DIR}/vault.hcl" > /dev/null <<VAULTCONFIG
ui = true
disable_mlock = true
api_addr = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"


listener "tcp" {
  address          = "127.0.0.1:8200"
  cluster_address  = "127.0.0.1:8201"
  tls_disable      = true
}

storage "raft" {
  path    = "/opt/vault"
  node_id = "vault-1"
}
VAULTCONFIG

sudo chown --recursive vault:vault "${VAULT_CONFIG_DIR}"
sudo chmod 640 "${VAULT_CONFIG_DIR}/vault.hcl"


echo "Creating vault systemd service"
sudo tee /etc/systemd/system/vault.service > /dev/null <<SYSDSERVICE
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=VAULTBINDIR/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitIntervalSec=60
StartLimitBurst=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
SYSDSERVICE

sudo sed -i "s|VAULTBINDIR|$VAULT_DIR|g" /etc/systemd/system/vault.service
