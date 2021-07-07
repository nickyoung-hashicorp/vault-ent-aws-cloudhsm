provider "aws" {
  region = var.region
}

module "vault-ent" {
  source               = "./vault-ent-module"
  friendly_name_prefix = var.friendly_name_prefix
  vpc_id               = var.vpc_id
  # private subnet tags allow you to filter which subnets you will
  # deploy Vault into
  private_subnet_tags = {
    "Vault" = "deploy"
  }
  secrets_manager_arn   = var.secrets_manager_arn
  leader_tls_servername = var.leader_tls_servername
  lb_certificate_arn    = var.lb_certificate_arn
}