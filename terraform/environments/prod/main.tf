terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment after creating backend resources (terraform/backend/)
  # backend "s3" {
  #   bucket         = "prometheus-stack-state-xxxxx"
  #   key            = "prometheus/prod/terraform.tfstate"
  #   region         = "us-west-2"
  #   dynamodb_table = "prometheus-terraform-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

module "security_group" {
  source = "../../modules/security-group"

  name                = var.project_name
  vpc_id              = var.vpc_id
  environment         = var.environment
  ssh_cidr_blocks     = var.ssh_cidr_blocks
  allowed_cidr_blocks = var.allowed_cidr_blocks
}

module "secrets" {
  source = "../../modules/secrets"

  secret_names = [
    "prometheus/grafana",
    "prometheus/prometheus-auth",
    "prometheus/alertmanager-auth",
    "prometheus/alertmanager"
  ]
}

module "iam" {
  source = "../../modules/iam"

  name        = var.project_name
  environment = var.environment
}

module "ec2" {
  source = "../../modules/ec2"

  name                 = var.project_name
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  instance_count       = var.instance_count
  subnet_ids           = var.subnet_ids
  volume_size          = var.volume_size
  create_eip           = var.create_eip
  environment          = var.environment
  cost_center          = var.cost_center
  application          = var.application
  owner                = var.owner
  security_group_ids   = [module.security_group.security_group_id]
  iam_instance_profile = module.iam.instance_profile_name
}
