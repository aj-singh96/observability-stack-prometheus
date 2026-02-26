output "instance_ids" {
  value       = aws_instance.app[*].id
  description = "List of EC2 instance IDs"
}

output "instance_private_ips" {
  value       = aws_instance.app[*].private_ip
  description = "List of private IP addresses"
}

output "instance_public_ips" {
  value       = aws_instance.app[*].public_ip
  description = "List of public IP addresses (if associated)"
}

output "eip_allocation_ids" {
  value       = var.create_eip ? aws_eip.app[*].id : null
  description = "List of Elastic IP allocation IDs (if created)"
}

output "eip_public_ips" {
  value       = var.create_eip ? aws_eip.app[*].public_ip : null
  description = "List of Elastic IP public addresses (if created)"
}

output "iam_instance_profile" {
  value       = var.iam_instance_profile
  description = "IAM instance profile name used for instances"
}

output "availability_zones" {
  value       = distinct([for i in aws_instance.app : i.availability_zone])
  description = "List of AZs where instances are deployed"
}

output "instance_count" {
  value       = length(aws_instance.app)
  description = "Actual number of instances created"
}

output "detailed_monitoring_enabled" {
  value       = var.enable_detailed_monitoring
  description = "Whether detailed CloudWatch monitoring is enabled"
}
