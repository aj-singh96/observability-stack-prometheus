output "instance_ids" {
  description = "EC2 instance IDs"
  value       = module.ec2.instance_ids
}

output "instance_public_ips" {
  description = "EC2 instance public IPs"
  value       = module.ec2.instance_public_ips
}

output "instance_public_dns" {
  description = "EC2 instance public DNS names"
  value       = module.ec2.instance_public_dns
}

output "security_group_id" {
  description = "Security Group ID"
  value       = module.security_group.security_group_id
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "https://${module.ec2.instance_public_ips[0]}:9090"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "https://${module.ec2.instance_public_ips[0]}:3000"
}