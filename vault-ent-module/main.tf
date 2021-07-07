data "aws_region" "current" {}

module "networking" {
  source = "./modules/networking"

  vpc_id              = var.vpc_id
  private_subnet_tags = var.private_subnet_tags
}

module "kms" {
  source = "./modules/kms"

  user_supplied_kms_key_arn = var.user_supplied_kms_key_arn
  friendly_name_prefix      = var.friendly_name_prefix
  common_tags               = var.common_tags
  kms_key_deletion_window   = var.kms_key_deletion_window
}

module "iam" {
  source = "./modules/iam"

  friendly_name_prefix        = var.friendly_name_prefix
  aws_region                  = data.aws_region.current.name
  kms_key_arn                 = module.kms.kms_key_arn
  user_supplied_iam_role_name = var.user_supplied_iam_role_name
  secrets_manager_arn         = var.secrets_manager_arn
}

module "user_data" {
  source = "./modules/user_data"

  friendly_name_prefix   = var.friendly_name_prefix
  aws_region             = data.aws_region.current.name
  kms_key_arn            = module.kms.kms_key_arn
  vault_version          = var.vault_version
  supplied_userdata_path = var.supplied_userdata_path
  secrets_manager_arn    = var.secrets_manager_arn
  leader_tls_servername  = var.leader_tls_servername
}

module "vm" {
  source = "./modules/vm"

  common_tags               = var.common_tags
  vpc_id                    = module.networking.vpc_id
  allowed_inbound_cidrs     = var.allowed_inbound_cidrs_lb
  allowed_inbound_cidrs_ssh = var.allowed_inbound_cidrs_ssh
  friendly_name_prefix      = var.friendly_name_prefix
  lb_type                   = var.lb_type
  node_count                = var.node_count
  vault_subnets             = module.networking.vault_subnet_ids
  instance_type             = var.instance_type
  key_name                  = var.key_name
  userdata_script           = module.user_data.vault_userdata_base64_encoded
  aws_iam_instance_profile  = module.iam.aws_iam_instance_profile
  vault_lb_sg_id            = module.loadbalancer.vault_lb_sg_id
  vault_target_group_arn    = module.loadbalancer.vault_target_group_arn
  user_supplied_ami_id      = var.user_supplied_ami_id
}

module "loadbalancer" {
  source = "./modules/load_balancer"

  common_tags           = var.common_tags
  allowed_inbound_cidrs = var.allowed_inbound_cidrs_lb
  friendly_name_prefix  = var.friendly_name_prefix
  lb_subnets            = module.networking.vault_subnet_ids
  lb_type               = var.lb_type
  ssl_policy            = var.ssl_policy
  vpc_id                = module.networking.vpc_id
  vault_sg_id           = module.vm.vault_sg_id
  vault_lb_health_check = var.vault_lb_health_check
  lb_certificate_arn    = var.lb_certificate_arn
}
