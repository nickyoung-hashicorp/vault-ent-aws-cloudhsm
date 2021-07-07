provider "aws" {
  region = "us-east-1"
}

module "vault-ent" {
  source               = "./vault-ent-module"
  friendly_name_prefix = "nyoung"
  vpc_id               = "vpc-07907b833ce2c4ed3"
  # private subnet tags allow you to filter which subnets you will
  # deploy Vault into
  private_subnet_tags = {
    "Vault" = "deploy"
  }
  secrets_manager_arn   = "arn:aws:secretsmanager:us-east-1:711129375688:secret:nyoung-tls-secret-cjcdIg"
  leader_tls_servername = "vault.server.com"
  lb_certificate_arn    = "arn:aws:acm:us-east-1:711129375688:certificate/7c62baca-06da-4701-a80d-dee8572c480e"
}

output "vault_lb_dns_name" {
  description = "DNS name of Vault load balancer"
  value       = module.vault-ent.vault_lb_dns_name
}

output "vault_lb_zone_id" {
  description = "Zone ID of Vault load balancer"
  value       = module.vault-ent.vault_lb_zone_id
}

output "vault_lb_arn" {
  description = "ARN of Vault load balancer"
  value       = module.vault-ent.vault_lb_arn
}

output "vault_target_group_arn" {
  description = "Target group ARN to register Vault nodes with"
  value       = module.vault-ent.vault_target_group_arn
}