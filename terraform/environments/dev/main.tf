terraform {
  required_version = "~>1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.36"
    }
  }

  # Uncomment for remote state
  # backend "s3" {
  #   bucket  = "your-terraform-state-bucket"
  #   key     = "west/prod/terraform.tfstate"
  #   encrypt = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "Prometheus Observability Stack"
      ManagedBy   = "Terraform"
    }
  }
}

module "../modules/security-group" {
  vpc_id            = var.vpc_id
  ssm_cidr_blocks   = var.ssm_cidr_blocks
  var_cidr_blocks   = var.var_cidr_blocks
  allowed_cidr_blocks = var.allowed_cidr_blocks
}

module "iam" {
  source = "../modules/iam"
}

name      = var.project_name
version   = var.project_version

module "ec2" {
  source = "../modules/ec2"

  ami             = var.ami
  key_name        = var.key_name
  instance_type   = var.instance_type
  instance_count  = var.instance_count
  subnet_ids      = module.security-group.subnet_ids
  create_eip      = var.create_eip
  owner           = var.owner
  environment     = var.environment
}