variable "vpc_id" {
  type        = string
  description = "VPC ID to create security group in"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed for SSH access (e.g., ['10.0.0.0/8', '203.0.113.0/32'])"
}

variable "name" {
  type        = string
  default     = "prometheus-observability-stack"
  description = "Security group name"
}

variable "description" {
  type        = string
  default     = "Security group for Prometheus observability stack"
  description = "Security group description"
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, prod)"
}

variable "enable_metrics_export" {
  type        = bool
  default     = true
  description = "Allow inbound traffic on metrics ports (9090, 9091, 9100, 9093, 9094)"
}

variable "additional_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default     = []
  description = "Additional custom ingress rules to add to the security group"
}

variable "additional_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to security group"
}
