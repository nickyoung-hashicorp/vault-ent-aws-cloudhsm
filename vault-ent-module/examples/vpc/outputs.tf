output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_tags" {
  description = "tags of private subnets that will be used to filter them while installing Vault"
  value       = var.private_subnet_tags
}

output "private_subnets" {
  description = "List of private subnets"
  value       = module.vpc.private_subnets
}