# CloudHSM Cluster outputs
output "cloudhsm_cluster_id" {
  description = "The ID of the CloudHSM cluster"
  value       = aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster.cluster_id
}

output "cloudhsm_cluster_state" {
  description = "The state of the CloudHSM cluster"
  value       = aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster.cluster_state
}

output "cloudhsm_security_group_id" {
  description = "The security group ID created by the CloudHSM cluster"
  value       = aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster.security_group_id
}

output "cloudhsm_subnet_ids" {
  value = data.aws_subnet_ids.cloudhsm_v2_subnets.ids
}

# CloudHSM Module outputs
output "cloudhsm_hsm_id" {
  description = "The ID of the CloudHSM module"
  value       = aws_cloudhsm_v2_hsm.cloudhsm_v2_hsm.hsm_id
}

output "cloudhsm_hsm_state" {
  description = "The ID of the CloudHSM module"
  value       = aws_cloudhsm_v2_hsm.cloudhsm_v2_hsm.hsm_state
}

output "cloudhsm_hsm_eni_id" {
  description = "The ID of the ENI interface allocated for CloudHSM module"
  value       = aws_cloudhsm_v2_hsm.cloudhsm_v2_hsm.hsm_eni_id
}