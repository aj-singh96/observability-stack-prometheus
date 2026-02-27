# Terraform Backend Configuration

## Purpose

This directory contains Terraform resources to create and manage a remote backend for storing Terraform state files. The backend uses AWS S3 for state storage, DynamoDB for state locking, and IAM policies for access control.

## What Gets Created

### S3 Bucket (`terraform_state`)
- **Versioning**: Enabled (restore previous states if needed)
- **Encryption**: AES-256 (SSE-S3) enabled at rest
- **Block Public Access**: All options enabled
- **Lifecycle**: Old versions retained for 30 days
- **Cost**: ~$0.023/month for state storage + data transfer

### DynamoDB Table (`terraform_lock`)
- **Table Name**: `prometheus-terraform-lock`
- **Primary Key**: `LockID` (string)
- **Billing**: On-demand (pay per operation)
- **Cost**: ~$0.088/month for typical usage

### IAM Policy (`github-actions`)
- Grants GitHub Actions permission to read/write S3 state and DynamoDB locks
- Use this policy for CI/CD automation

**Total Estimated Cost**: ~$0.11/month

## Quick Start

### 1. Initialize and Apply Backend Resources

```bash
cd terraform/backend
terraform init
terraform apply
```

Note: This creates AWS resources in your default region. Terraform will prompt for confirmation before creating resources.

### 2. Capture Outputs

After `terraform apply`, note the outputs:
```
s3_bucket_name = "prometheus-stack-state-xxxxx"
s3_bucket_arn = "arn:aws:s3:::prometheus-stack-state-xxxxx"
dynamodb_table_name = "prometheus-terraform-lock"
dynamodb_table_arn = "arn:aws:dynamodb:us-west-2:123456789:table/prometheus-terraform-lock"
github_actions_policy_arn = "arn:aws:iam::123456789:policy/github-actions-terraform-policy"
```

### 3. Configure GitHub Secrets

Create these secrets in your GitHub repository (Settings → Secrets and variables → Actions):

| Secret Name | Value | Example |
|---|---|---|
| `TF_STATE_BUCKET` | S3 bucket name | `prometheus-stack-state-xxxxx` |
| `TF_STATE_LOCK_TABLE` | DynamoDB table name | `prometheus-terraform-lock` |
| `AWS_REGION` | AWS region | `us-west-2` |
| `AWS_ACCESS_KEY_ID` | IAM user access key | [See Manual Setup] |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key | [See Manual Setup] |
| `SSH_PRIVATE_KEY` | Base64 EC2 SSH key | `base64 -w0 ~/.ssh/your-key.pem` |

## Manual AWS CLI Setup

If not using GitHub Actions, configure AWS CLI:

```bash
# Store credentials
aws configure

# Verify access
aws s3 ls s3://prometheus-stack-state-xxxxx
aws dynamodb describe-table --table-name prometheus-terraform-lock
```

## Backend Configuration

After creating backend resources, add these blocks to your dev/prod environment Terraform files:

### Development Environment
**File**: `terraform/environments/dev/backend.tf`
```hcl
terraform {
  backend "s3" {
    bucket         = "prometheus-stack-state-xxxxx"
    key            = "prometheus/dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "prometheus-terraform-lock"
    encrypt        = true
  }
}
```

### Production Environment
**File**: `terraform/environments/prod/backend.tf`
```hcl
terraform {
  backend "s3" {
    bucket         = "prometheus-stack-state-xxxxx"
    key            = "prometheus/prod/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "prometheus-terraform-lock"
    encrypt        = true
  }
}
```

## State Migration

To migrate existing local state to remote backend:

```bash
cd terraform/environments/dev

# 1. Back up local state
cp terraform.tfstate terraform.tfstate.backup

# 2. Add backend configuration (backend.tf file above)

# 3. Reconfigure to use remote backend
terraform init

# When prompted: "Do you want to copy existing state to the new backend?"
# Answer: yes

# 4. Verify state is in S3
aws s3 ls s3://prometheus-stack-state-xxxxx/prometheus/dev/

# 5. Remove local state file
rm terraform.tfstate terraform.tfstate.backup terraform.tfstate.backup.backup
```

## Troubleshooting

### Error: "DynamoDB lock error"
**Cause**: Stale lock from interrupted apply  
**Solution**:
```bash
# View locks
aws dynamodb scan --table-name prometheus-terraform-lock

# Remove stale lock
aws dynamodb delete-item \
  --table-name prometheus-terraform-lock \
  --key '{"LockID":{"S":"prometheus/dev/terraform.tfstate"}}'
```

### Error: "Could not initialize remote state"
**Cause**: S3 bucket doesn't exist or no permissions  
**Solution**:
```bash
# Verify bucket exists
aws s3 ls s3://prometheus-stack-state-xxxxx

# Verify IAM permissions
aws iam get-role --role-name github-actions-role
```

### Error: "NoSuchKey" when running terraform apply
**Cause**: State file doesn't exist yet (first apply)  
**Solution**: This is normal. Run `terraform apply` to create the initial state file.

## Security Best Practices

1. **Enable Versioning**: Already enabled in S3 bucket (allows rollback)
2. **Block Public Access**: All public access is blocked
3. **Encryption**: All state files encrypted at rest (AES-256)
4. **State Locking**: DynamoDB prevents concurrent modifications
5. **Audit Logging**: Enable CloudTrail to log S3 access
6. **IAM Permissions**: Use least-privilege principle (provided policy is minimal)
7. **Secrets**: Never commit `terraform.tfstate` or AWS credentials to Git
8. **Backup**: State is automatically versioned (30-day retention)

### Enable S3 Access Logging (Optional)
```bash
aws s3api put-bucket-logging \
  --bucket prometheus-stack-state-xxxxx \
  --bucket-logging-status file:///dev/stdin <<< '{
    "LoggingEnabled": {
      "TargetBucket": "prometheus-stack-state-xxxxx-logs",
      "TargetPrefix": "s3-access-logs/"
    }
  }'
```

## Cleanup

To destroy backend resources (WARNING: Deletes S3 bucket and DynamoDB table):

```bash
cd terraform/backend

# Enable S3 bucket deletion (normally prevented to avoid data loss)
aws s3 rb s3://prometheus-stack-state-xxxxx --force

# Remove DynamoDB table
aws dynamodb delete-table --table-name prometheus-terraform-lock

# Destroy IAM policy and role
terraform destroy
```

**WARNING**: This destroys your entire Terraform state history. Ensure state is backed up before proceeding.

## References

- [Terraform S3 Backend Documentation](https://www.terraform.io/language/settings/backends/s3)
- [AWS S3 Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/BestPractices.html)
- [AWS DynamoDB for Terraform State Locking](https://www.terraform.io/language/state/locking)
