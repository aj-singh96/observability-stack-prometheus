output "s3_bucket_name" {
  description = "S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN of S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table for Terraform lock"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "dynamodb_table_arn" {
  description = "ARN of DynamoDB table for Terraform lock"
  value       = aws_dynamodb_table.terraform_lock.arn
}

output "github_actions_policy_arn" {
  description = "ARN of IAM policy for GitHub Actions"
  value       = aws_iam_policy.github_actions.arn
}

output "backend_config" {
  description = "Backend configuration and GitHub Secrets to configure"
  value       = <<-EOT
# Development Backend Configuration
# In: terraform/environments/dev/backend.tf
terraform {
  backend "s3" {
    bucket         = "${aws_s3_bucket.terraform_state.id}"
    key            = "prometheus/dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "${aws_dynamodb_table.terraform_lock.name}"
    encrypt        = true
  }
}

# Production Backend Configuration
# In: terraform/environments/prod/backend.tf
terraform {
  backend "s3" {
    bucket         = "${aws_s3_bucket.terraform_state.id}"
    key            = "prometheus/prod/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "${aws_dynamodb_table.terraform_lock.name}"
    encrypt        = true
  }
}

# GitHub Secrets to Configure
# In: GitHub repo → Settings → Secrets and variables → Actions

TF_STATE_BUCKET="${aws_s3_bucket.terraform_state.id}"
TF_STATE_LOCK_TABLE="${aws_dynamodb_table.terraform_lock.name}"
AWS_REGION="us-west-2"
AWS_ACCESS_KEY_ID="[Create IAM user for CI/CD]"
AWS_SECRET_ACCESS_KEY="[Create IAM user for CI/CD]"
SSH_PRIVATE_KEY="[Base64 encoded SSH private key for EC2 access]"
  EOT
}
