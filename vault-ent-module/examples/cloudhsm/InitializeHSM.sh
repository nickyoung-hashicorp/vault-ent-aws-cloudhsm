# Get the CSR (AWS CLI)
export CLUSTER_ID=$(terraform output -json | jq -r .cloudhsm_cluster_id.value)
aws cloudhsmv2 describe-clusters --filters clusterIds=${CLUSTER_ID} \
                                   --output text \
                                   --query 'Clusters[].Certificates.ClusterCsr' \
                                   > ClusterCsr.csr

# Create a private key using "hashi" as the pass phrase
openssl genrsa -aes256 -passout pass:hashi -out customerCA.key 2048


# Use private key to create self-signed certificate
openssl req -new -x509 -days 3652 -key customerCA.key -out customerCA.crt

# Sign the Cluster CSR
openssl x509 -req -days 3652 -in ClusterCsr.csr \
                              -CA customerCA.crt \
                              -CAkey customerCA.key \
                              -CAcreateserial \
                              -out CustomerHsmCertificate.crt

# Initialize the cluster
aws cloudhsmv2 initialize-cluster --cluster-id ${CLUSTER_ID} \
                                    --signed-cert file://CustomerHsmCertificate.crt \
                                    --trust-anchor file://customerCA.crt

# Check state of initialization, should change from INITIALIZE_IN_PROGRESS to INITIALIZED
aws cloudhsmv2 describe-clusters --filters clusterIds=${CLUSTER_ID} \
                                   --output text \
                                   --query 'Clusters[].State'

# Clean up cert files
rm customer* Customer* Cluster*