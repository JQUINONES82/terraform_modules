terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create some example IAM resources to attach the policy to
resource "aws_iam_user" "example_user" {
  name = "example-policy-user"
  path = "/example/"

  tags = {
    Environment = "dev"
    Purpose     = "policy-attachment-example"
  }
}

resource "aws_iam_group" "example_group" {
  name = "example-policy-group"
  path = "/example/"
}

resource "aws_iam_role" "example_role" {
  name = "example-policy-role"
  path = "/example/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = "dev"
    Purpose     = "policy-attachment-example"
  }
}

# Create IAM policy with attachments
module "policy_with_attachments" {
  source = "../../"

  name        = "cloudwatch-logs-policy"
  description = "Policy for CloudWatch Logs access with automatic attachments"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/*"
      },
      {
        Sid    = "CloudWatchMetrics"
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "AWS/Lambda"
          }
        }
      }
    ]
  })

  # Attach to the created resources
  attach_to_users  = [aws_iam_user.example_user.name]
  attach_to_groups = [aws_iam_group.example_group.name]
  attach_to_roles  = [aws_iam_role.example_role.name]

  tags = {
    Environment = "dev"
    Purpose     = "cloudwatch-access"
    Service     = "lambda"
  }
}
