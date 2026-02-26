variable "secret_names" {
  description = "List of secret names to create in AWS Secrets Manager"
  type        = list(string)
}
