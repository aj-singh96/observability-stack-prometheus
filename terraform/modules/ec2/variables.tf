variable "ami" { type = string }
variable "key_name" { type = string }
variable "instance_type" { type = string }
variable "instance_count" { type = number }
variable "subnet_ids" { type = list(string) }
variable "create_eip" { type = bool }
variable "owner" { type = string }
variable "environment" { type = string }
