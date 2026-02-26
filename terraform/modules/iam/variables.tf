variable "name_prefix" {
  type        = string
  default     = "prometheus-stack"
  description = "Prefix for IAM role and policy names"
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, prod)"
}

variable "secrets_manager_secret_names" {
  type        = list(string)
  default     = ["grafana_admin_password", "prometheus_token", "alertmanager_webhook", "smtp_password"]
  description = "List of Secrets Manager secret names to grant read access"
}

variable "cost_explorer_enabled" {
  type        = bool
  default     = true
  description = "Enable AWS Cost Explorer permissions for cost-exporter script"
}

variable "additional_policy_arns" {
  type        = list(string)
  default     = []
  description = "Additional IAM policy ARNs to attach to the instance role"
}

variable "additional_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to IAM resources"
}

