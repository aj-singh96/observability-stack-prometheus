resource "aws_security_group" "instance_sg" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  # SSH (restricted to allowed_cidr_blocks)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "SSH access from allowed CIDR blocks"
  }

  # HTTP (public)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  # HTTPS (public)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from anywhere"
  }

  # Prometheus API (restricted)
  dynamic "ingress" {
    for_each = var.enable_metrics_export ? [1] : []
    content {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      description = "Prometheus API access"
    }
  }

  # Cost Exporter (restricted)
  dynamic "ingress" {
    for_each = var.enable_metrics_export ? [1] : []
    content {
      from_port   = 9091
      to_port     = 9091
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      description = "Cost exporter metrics"
    }
  }

  # Node Exporter (restricted)
  dynamic "ingress" {
    for_each = var.enable_metrics_export ? [1] : []
    content {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      description = "Node exporter metrics"
    }
  }

  # AlertManager API (restricted)
  dynamic "ingress" {
    for_each = var.enable_metrics_export ? [1] : []
    content {
      from_port   = 9093
      to_port     = 9093
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      description = "AlertManager API access"
    }
  }

  # AlertManager Clustering (restricted)
  dynamic "ingress" {
    for_each = var.enable_metrics_export ? [1] : []
    content {
      from_port   = 9094
      to_port     = 9094
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      description = "AlertManager clustering"
    }
  }

  # Additional custom ingress rules
  dynamic "ingress" {
    for_each = var.additional_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    {
      Name        = var.name
      Environment = var.environment
    },
    var.additional_tags
  )
}

