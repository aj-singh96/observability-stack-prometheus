output "s3_bucket_name" {
  value       = ""
  description = "S3 bucket name for terraform state (populated after apply)"
}

output "s3_bucket_arn" {
  value       = ""
  description = "S3 bucket ARN for terraform state (populated after apply)"
}

output "dynamodb_table_name" {
  value       = ""
  description = "DynamoDB table name used for state locking"
}

output "dynamodb_table_arn" {
  value       = ""
  description = "DynamoDB table ARN used for state locking"
}

output "github_actions_policy_arn" {
  value       = ""
  description = "ARN of IAM policy for GitHub Actions to access the backend"
}

output "backend_config" {
  value = <<EOF
S3 backend configuration example (replace placeholders):

dev:
  bucket = "<S3_BUCKET_NAME>"
  key    = "dev/terraform.tfstate"
  region = "<AWS_REGION>"
  dynamodb_table = "<DYNAMODB_TABLE_NAME>"

prod:
  bucket = "<S3_BUCKET_NAME>"
  key    = "prod/terraform.tfstate"
  region = "<AWS_REGION>"
  dynamodb_table = "<DYNAMODB_TABLE_NAME>"

# Configure these values as GitHub Secrets (e.g. TF_BACKEND_DEV, TF_BACKEND_PROD)
EOF
}
