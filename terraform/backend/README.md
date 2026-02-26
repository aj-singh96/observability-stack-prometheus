# Terraform Backend

## Purpose

This folder contains Terraform resources to create a remote backend for storing Terraform state and a DynamoDB table for locking.

## Prerequisites

- AWS credentials with permissions to create S3 buckets, DynamoDB tables and IAM policies.
- `terraform` CLI installed.

## What it creates

- S3 bucket for Terraform state (versioning + encryption)
- DynamoDB table for state locking
- IAM policy for GitHub Actions (optional)

## Usage

1. Initialize Terraform in this folder and apply:

```sh
terraform init
terraform apply
```

2. After apply, capture the backend configuration shown in the `backend_config` output and store it in your CI/CD secrets (for example `TF_BACKEND_DEV` and `TF_BACKEND_PROD`).

## Configure dev/prod backends

Use the example `backend_config` output to populate the S3 bucket/key/region/dynamodb values for your environment.

## GitHub Secrets

Create a repository secret (e.g., `TF_BACKEND_DEV`) containing the S3 backend configuration for the dev environment, and similarly for prod.
