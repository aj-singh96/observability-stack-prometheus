variable "name_prefix" {
  type    = string
  default = "prometheus-stack"
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "secrets_and_cost" {
  name = "${var.name_prefix}-secrets-cost"
  role = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.secrets_cost.json
}

data "aws_iam_policy_document" "secrets_cost" {
  statement {
    actions = ["secretsmanager:GetSecretValue","secretsmanager:DescribeSecret"]
    resources = ["*"]
  }
  statement {
    actions = ["ce:GetCostAndUsage","ce:GetCostForecast"]
    resources = ["*"]
  }
}

output "role_name" {
  value = aws_iam_role.ec2_role.name
}
