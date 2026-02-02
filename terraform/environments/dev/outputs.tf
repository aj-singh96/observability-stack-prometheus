output "instance_ids" {
  description = "EC2 instance IDs"
  value       = module.ec2.instance_ids
}

output "instance_public_ip" {
  description = "EC2 instance public IP"
  value       = module.ec2.instance_public_ip
}

output "instance_public_dns" {
  description = "EC2 instance public DNS"
  value       = module.ec2.instance_public_dns
}

output "security_group_id" {
  description = "Security Group ID"
  value       = module.security-group.security_group_id
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "https://module.ec2.instance_public_ip:9090"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "https://module.ec2.instance_public_ip:3000"
}

output "alertmanager_url" {
  description = "Alertmanager URL"
  value       = "https://module.ec2.instance_public_ip:9093"
}