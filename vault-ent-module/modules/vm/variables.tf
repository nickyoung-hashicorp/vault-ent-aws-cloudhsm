variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources"
}

variable "allowed_inbound_cidrs_ssh" {
  type        = list(string)
  description = "List of CIDR blocks to give SSH access to Vault nodes"
}

variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Vault will be deployed"
}

variable "node_count" {
  type        = number
  description = "Number of Vault nodes to deploy in ASG"
}

variable "vault_subnets" {
  type        = list(string)
  description = "Private subnets where Vault will be deployed"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "key pair to use for SSH access to instance"
}

variable "userdata_script" {
  type        = string
  description = "Userdata script for EC2 instance"
}

variable "aws_iam_instance_profile" {
  type        = string
  description = "IAM instance profile name to use for Vault instances"
}

variable "vault_lb_sg_id" {
  type        = string
  description = "Security group ID of Vault load balancer"
}

variable "vault_target_group_arn" {
  type        = string
  description = "Target group ARN to register Vault nodes with"
}

variable "lb_type" {
  description = "The type of load balancer to provison: network or application."
  type        = string
}

variable "allowed_inbound_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks to permit inbound traffic from to load balancer"
}

variable "user_supplied_ami_id" {
  type        = string
  description = "AMI ID to use with Vault instances"
}
