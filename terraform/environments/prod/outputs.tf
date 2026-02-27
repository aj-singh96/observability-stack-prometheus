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

output "elastic_ips" {
  description = "Elastic IPs allocated to instances"
  value       = module.ec2.elastic_ips
}

output "security_group_id" {
  description = "Security Group ID"
  value       = module.security_group.security_group_id
}

output "prometheus_url" {
  description = "Prometheus URL (prefers Elastic IP)"
  value       = "https://${try(module.ec2.elastic_ips[0], module.ec2.instance_public_ips[0])}:9090"
}

output "grafana_url" {
  description = "Grafana URL (prefers Elastic IP)"
  value       = "https://${try(module.ec2.elastic_ips[0], module.ec2.instance_public_ips[0])}:3000"
}

output "alertmanager_url" {
  description = "AlertManager URL (prefers Elastic IP)"
  value       = "https://${try(module.ec2.elastic_ips[0], module.ec2.instance_public_ips[0])}:9093"
}
