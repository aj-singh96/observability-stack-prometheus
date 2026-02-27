variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "prometheus-stack-prod"
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EC2 instance"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID (Ubuntu 22.04 LTS recommended)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 50
}

variable "create_eip" {
  description = "Create Elastic IP for the instance"
  type        = bool
  default     = true
}

variable "owner" {
  description = "Owner tag for resources"
  type        = string
}

variable "cost_center" {
  description = "Cost center tag for billing"
  type        = string
}

variable "application" {
  description = "Application name tag"
  type        = string
  default     = "monitoring"
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access (required for prod)"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed for HTTP/HTTPS access (required for prod)"
  type        = list(string)
}
