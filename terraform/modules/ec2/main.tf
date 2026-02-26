variable "ami" {}
variable "key_name" {}
variable "instance_type" {}
variable "instance_count" { type = number }
variable "subnet_ids" { type = list(string) }
variable "create_eip" { type = bool }
variable "owner" { type = string }
variable "environment" { type = string }

resource "aws_instance" "app" {
  count         = var.instance_count
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name        = "prometheus-${var.environment}-${count.index}"
    Owner       = var.owner
    Environment = var.environment
  }

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = file("${path.module}/user-data.sh")
}

resource "aws_eip" "eip" {
  count    = var.create_eip ? var.instance_count : 0
  instance = aws_instance.app[count.index].id
}

output "instance_ids" {
  value = aws_instance.app[*].id
}
