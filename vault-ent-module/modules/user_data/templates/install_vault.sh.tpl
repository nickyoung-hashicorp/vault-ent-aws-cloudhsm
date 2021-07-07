#!/usr/bin/env bash

export instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
export local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

# install package

curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update
apt-get install -y vault-enterprise=${vault_version}+ent awscli jq

echo "Configuring system time"
timedatectl set-timezone UTC

# removing any default installation files from /opt/vault/tls/
rm -rf /opt/vault/tls/*

touch /opt/vault/tls/{vault-cert.pem,vault-ca.pem,vault-key.pem}
chown vault:vault /opt/vault/tls/{vault-cert.pem,vault-ca.pem,vault-key.pem}
chmod 0640 /opt/vault/tls/{vault-cert.pem,vault-ca.pem,vault-key.pem}

secret_result=$(aws secretsmanager get-secret-value --secret-id ${secrets_manager_arn} --region ${region} --output text --query SecretString)

jq -r .vault_cert <<< "$secret_result" | base64 -d > /opt/vault/tls/vault-cert.pem

jq -r .vault_ca <<< "$secret_result" | base64 -d > /opt/vault/tls/vault-ca.pem

jq -r .vault_pk <<< "$secret_result" | base64 -d > /opt/vault/tls/vault-key.pem

cat << EOF > /etc/vault.d/vault.hcl
disable_performance_standby = true
ui = true
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "$instance_id"
  retry_join {
    auto_join = "provider=aws region=${region} tag_key=${name}-vault tag_value=server"
    auto_join_scheme = "https"
    leader_tls_servername = "${leader_tls_servername}"
    leader_ca_cert_file = "/opt/vault/tls/vault-ca.pem"
    leader_client_cert_file = "/opt/vault/tls/vault-cert.pem"
    leader_client_key_file = "/opt/vault/tls/vault-key.pem"
  }
}

cluster_addr = "https://$local_ipv4:8201"
api_addr = "https://0.0.0.0:8200"

listener "tcp" {
 address     = "0.0.0.0:8200"
 tls_disable = 0
 tls_cert_file      = "/opt/vault/tls/vault-cert.pem"
 tls_key_file       = "/opt/vault/tls/vault-key.pem"
 tls_client_ca_file = "/opt/vault/tls/vault-ca.pem"
}

# Provide your AWS CloudHSM cluster connection information
seal "pkcs11" {
  lib = "/opt/cloudhsm/lib/libcloudhsm_pkcs11.so"
  slot = "1"
  pin = "vault:Password1"
  key_label = "hsm_demo"
  hmac_key_label = "hsm_hmac_demo"
  generate_key = "true"
}
EOF

chown -R vault:vault /etc/vault.d/*
chmod -R 640 /etc/vault.d/*

systemctl enable vault
systemctl start vault

echo "Setup Vault profile"
cat <<PROFILE | sudo tee /etc/profile.d/vault.sh
export VAULT_ADDR="https://127.0.0.1:8200"
export VAULT_CACERT="/opt/vault/tls/vault-ca.pem"
export VAULT_CLIENT_CERT="/opt/vault/tls/vault-cert.pem"
export VAULT_CLIENT_KEY="/opt/vault/tls/vault-key.pem"
PROFILE
