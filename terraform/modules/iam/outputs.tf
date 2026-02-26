output "instance_profile_name" {
  value       = aws_iam_instance_profile.app_profile.name
  description = "IAM instance profile name for EC2 role assumption"
}

output "instance_profile_arn" {
  value       = aws_iam_instance_profile.app_profile.arn
  description = "IAM instance profile ARN"
}

output "instance_role_name" {
  value       = aws_iam_role.app_role.name
  description = "IAM role name for the instance"
}

output "instance_role_arn" {
  value       = aws_iam_role.app_role.arn
  description = "IAM role ARN"
}

output "instance_role_id" {
  value       = aws_iam_role.app_role.id
  description = "IAM role ID"
}

output "secrets_manager_policy_arn" {
  value       = aws_iam_policy.secrets_manager_policy.arn
  description = "Secrets Manager read policy ARN"
}

output "cost_explorer_policy_arn" {
  value       = var.cost_explorer_enabled ? aws_iam_policy.cost_explorer_policy[0].arn : null
  description = "Cost Explorer policy ARN (if enabled)"
}
