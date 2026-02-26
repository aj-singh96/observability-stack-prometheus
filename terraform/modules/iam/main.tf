# EC2 instance assume role
resource "aws_iam_role" "app_role" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(
    {
      Name        = "${var.name_prefix}-ec2-role"
      Environment = var.environment
    },
    var.additional_tags
  )
}

# EC2 service can assume this role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.name_prefix}-instance-profile"
  role = aws_iam_role.app_role.name
}

# Secrets Manager policy
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "${var.name_prefix}-secrets-manager"
  description = "Allow reading secrets from AWS Secrets Manager"
  policy      = data.aws_iam_policy_document.secrets_manager.json
}

data "aws_iam_policy_document" "secrets_manager" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      "arn:aws:secretsmanager:*:*:secret:${var.name_prefix}*"
    ]
  }
}

# Cost Explorer policy (optional)
resource "aws_iam_policy" "cost_explorer_policy" {
  count       = var.cost_explorer_enabled ? 1 : 0
  name        = "${var.name_prefix}-cost-explorer"
  description = "Allow cost-exporter to query AWS Cost and Usage, Cost Forecast"
  policy      = data.aws_iam_policy_document.cost_explorer[0].json
}

data "aws_iam_policy_document" "cost_explorer" {
  count = var.cost_explorer_enabled ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "ce:GetCostAndUsage",
      "ce:GetCostForecast"
    ]
    resources = ["*"]
  }
}

# Attach Secrets Manager policy
resource "aws_iam_role_policy_attachment" "secrets_manager" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

# Attach Cost Explorer policy (if enabled)
resource "aws_iam_role_policy_attachment" "cost_explorer" {
  count      = var.cost_explorer_enabled ? 1 : 0
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.cost_explorer_policy[0].arn
}

# Attach additional policies
resource "aws_iam_role_policy_attachment" "additional" {
  for_each   = toset(var.additional_policy_arns)
  role       = aws_iam_role.app_role.name
  policy_arn = each.value
}

