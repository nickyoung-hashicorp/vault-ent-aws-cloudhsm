variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Vault will be deployed"
}

variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources"
}

variable "lb_subnets" {
  type        = list(string)
  description = "Subnets where load balancer will be deployed"
}

variable "lb_type" {
  description = "The type of load balancer to provison: network or application."
  type        = string
}

variable "vault_sg_id" {
  type        = string
  description = "Security group ID of Vault cluster"
}

variable "allowed_inbound_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks to permit inbound traffic from to load balancer"
}

variable "vault_lb_health_check" {
  type        = string
  description = "The endpoint to check for Vault's health status."
}

variable "ssl_policy" {
  type        = string
  description = "SSL policy to use on LB listener"
}

variable "lb_certificate_arn" {
  type        = string
  description = "ARN of TLS certificate imported into ACM for use with LB listener"
}
