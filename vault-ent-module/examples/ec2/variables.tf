variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID gathered from the output of the VPC deployment"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "friendly_name_prefix" {
  description = "Prefix for resource names (e.g. \"prod\")"
  type        = string
}

variable "private_subnet_tags" {
  type        = map(string)
  description = "Tags for private subnets. Be sure to provide these tags to the Vault installation module."
}