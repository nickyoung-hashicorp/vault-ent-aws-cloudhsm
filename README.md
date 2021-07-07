## Deploy VPC
cd vault-ent-module/examples/vpc
terraform init
terraform plan
terraform apply -auto-approve

# Find the VPC ID
terraform output -json | jq -r

#