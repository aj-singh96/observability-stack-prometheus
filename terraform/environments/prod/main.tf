terraform {
  required_version = "~>1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.36"
    }
  }

  backend "s3" {
    bucket         = var.state_bucket
    key            = "prod/terraform.tfstate"
    encrypt        = true
    dynamodb_table = var.lock_table
    region         = var.region
  }
}

provider "aws" {
  region = var.region
}

module "security-group" {
  source              = "../../modules/security-group"
  vpc_id              = var.vpc_id
  allowed_cidr_blocks = var.allowed_cidr_blocks
}

module "secrets" {
  source = "../../modules/secrets"
  secret_names = [
    "grafana_admin_password",
    "prometheus_basic_auth",
    "alertmanager_basic_auth",
    "smtp_credentials",
  ]
}

module "iam" {
  source = "../../modules/iam"
}

module "ec2" {
  source         = "../../modules/ec2"
  ami            = var.ami
  key_name       = var.key_name
  instance_type  = var.instance_type
  instance_count = var.instance_count
  subnet_ids     = var.subnet_ids
  create_eip     = true
  owner          = var.owner
  environment    = var.environment
}
