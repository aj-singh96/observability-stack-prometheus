terraform {
  required_version = "~>1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.36"
    }
  }
}

provider "aws" {
  region = var.region
}

module "security-group" {
  source = "../../modules/security-group"
  vpc_id = var.vpc_id
  allowed_cidr_blocks = var.allowed_cidr_blocks
}

module "iam" {
  source = "../../modules/iam"
}

module "ec2" {
  source = "../../modules/ec2"
  ami             = var.ami
  key_name        = var.key_name
  instance_type   = var.instance_type
  instance_count  = var.instance_count
  subnet_ids      = var.subnet_ids
  create_eip      = true
  owner           = var.owner
  environment     = var.environment
}
