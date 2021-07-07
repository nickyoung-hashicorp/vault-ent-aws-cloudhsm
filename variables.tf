variable "region" {
  description = "Provide your desired AWS region"
  default     = "us-east-1"
}

variable "friendly_name_prefix" {
  description = "Prepends a name to tagged resources"
  default     = "instruqt"
}

variable "vpc_id" {
  description = "VPC ID you wish to deploy into.  Created as an output of ./vault-ent-module/examples/vpc"
  default     = "vpc-123456789ab0c1de3"
}

variable "secrets_manager_arn" {
  description = "AWS Secrets Manager ARN where TLS certs are stored.  Created as an output of ./vault-ent-module/examples/secrets-manager-acm"
  default     = "arn:aws:secretsmanager:us-east-1:AWSACCOUNTNUMBER:secret:abc-tls-secret-vwXyZ"
}

variable "leader_tls_servername" {
  description = "The shared DNS SAN of the TLS certs being used"
  default     = "vault.server.com"
}

variable "lb_certificate_arn" {
  description = "The cert ARN to be used on the Vault LB listener.  Created as an output of ./vault-ent-module/examples/secrets-manager-acm."
  default     = "arn:aws:acm:us-east-1:AWSACCOUNTNUMBER:certificate/1234abcd-78ef-9101-g12h-ijk1314l156m"
}