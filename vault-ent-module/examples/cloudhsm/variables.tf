variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources into"
}

variable "friendly_name_prefix" {
  type        = string
  description = "Prefix for resource names (e.g. \"prod\")"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID gathered from the output of the VPC deployment"
}