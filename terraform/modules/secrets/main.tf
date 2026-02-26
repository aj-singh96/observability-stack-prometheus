variable "secret_names" {
  type = list(string)
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each = toset(var.secret_names)
  name     = each.value

  tags = {
    ManagedBy = "Terraform"
  }
}

output "secret_arns" {
  value = { for k, v in aws_secretsmanager_secret.secrets : k => v.arn }
}
