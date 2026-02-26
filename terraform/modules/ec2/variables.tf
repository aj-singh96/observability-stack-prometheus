variable "ami" {
  type        = string
  description = "EC2 AMI ID (e.g., Ubuntu 24.04 LTS)"
}

variable "key_name" {
  type        = string
  description = "EC2 Key Pair name for SSH access"
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type (t3.small, t3.medium, t3.large, etc.)"
}

variable "instance_count" {
  type        = number
  default     = 1
  description = "Number of instances to launch"
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for instance placement"
}

variable "create_eip" {
  type        = bool
  default     = false
  description = "Create Elastic IP address (recommended for prod)"
}

variable "owner" {
  type        = string
  description = "Owner name for tagging (e.g., 'observability-team')"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "enable_detailed_monitoring" {
  type        = bool
  default     = false
  description = "Enable detailed CloudWatch monitoring (1-minute intervals)"
}

variable "root_volume_size_gb" {
  type        = number
  default     = 10
  description = "Root volume size in GB (gp3)"
  validation {
    condition     = var.root_volume_size_gb >= 10 && var.root_volume_size_gb <= 100
    error_message = "Root volume size must be between 10 and 100 GB."
  }
}

variable "root_volume_encrypted" {
  type        = bool
  default     = true
  description = "Enable EBS encryption for root volume"
}

variable "backup_retention_days" {
  type        = number
  default     = 7
  description = "Number of days to retain EBS snapshots"
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 30
    error_message = "Backup retention must be 1-30 days."
  }
}

variable "additional_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources"
}

variable "associate_public_ip" {
  type        = bool
  default     = true
  description = "Associate public IP address to instances"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name for EC2 role assumption"
}
