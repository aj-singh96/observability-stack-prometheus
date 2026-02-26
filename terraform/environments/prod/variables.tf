variable "region" { default = "us-east-1" }
variable "state_bucket" { description = "S3 bucket for Terraform state" type = string }
variable "lock_table" { description = "DynamoDB table for state locking" type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "ami" { type = string }
variable "key_name" { type = string }
variable "instance_type" { default = "t3.small" }
variable "instance_count" { default = 1 }
variable "owner" { default = "team" }
variable "environment" { default = "prod" }
variable "allowed_cidr_blocks" { type = list(string) }
