variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "prometheus-stack-dev"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "ami" {
  description = "AMI Ubuntu 24.04 LTS"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

variable "volume_size" {
  description = "Root volume size GB"
  type        = number
  default     = 20
}

variable "create_eip" {
  description = "Create Elastic IP"
  type        = bool
  default     = false
}

variable "owner" {
  description = "Owner tag"
  type        = string
}

variable "cost_center" {
  description = "Cost center tag"
  type        = string
}

variable "application" {
  description = "Application tag"
  type        = string
  default     = "monitoring"
}

variable "ssm_cidr_blocks" {
  description = "CIDR blocks for SSM access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks for monitoring ports"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}