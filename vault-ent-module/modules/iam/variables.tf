variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources"
}

variable "aws_region" {
  type        = string
  description = "Specific AWS region being used"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN used for Vault auto-unseal permissions"
}

variable "user_supplied_iam_role_name" {
  type        = string
  description = "(OPTIONAL) User-provided IAM role name. This will be used for the instance profile provided to the AWS launch configuration. The minimum permissions must match the defaults generated by the IAM submodule for cloud auto-join and auto-unseal."
}

variable "secrets_manager_arn" {
  type        = string
  description = "Secrets manager ARN where TLS cert info is stored"
}
