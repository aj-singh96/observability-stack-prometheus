output "security_group_id" {
  value       = aws_security_group.instance_sg.id
  description = "Security group ID for EC2 instances"
}

output "security_group_arn" {
  value       = aws_security_group.instance_sg.arn
  description = "Security group ARN"
}

output "security_group_name" {
  value       = aws_security_group.instance_sg.name
  description = "Security group name"
}

output "ingress_rule_count" {
  value       = length(aws_security_group.instance_sg.ingress)
  description = "Number of ingress rules"
}

output "egress_rule_count" {
  value       = length(aws_security_group.instance_sg.egress)
  description = "Number of egress rules"
}
