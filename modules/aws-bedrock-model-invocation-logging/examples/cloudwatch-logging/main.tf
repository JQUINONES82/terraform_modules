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
  region = var.aws_region
}

# Create CloudWatch log group for Bedrock logging
resource "aws_cloudwatch_log_group" "bedrock_logs" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# IAM role for Bedrock to write to CloudWatch
resource "aws_iam_role" "bedrock_cloudwatch" {
  name = "${var.resource_prefix}-bedrock-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for CloudWatch access
resource "aws_iam_role_policy" "bedrock_cloudwatch" {
  name = "${var.resource_prefix}-bedrock-cloudwatch-policy"
  role = aws_iam_role.bedrock_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.bedrock_logs.arn}:*"
      }
    ]
  })
}

# Configure Bedrock model invocation logging to CloudWatch
module "bedrock_logging" {
  source = "../../"

  logging_config = {
    embedding_data_delivery_enabled = var.enable_embedding_data
    image_data_delivery_enabled     = var.enable_image_data
    text_data_delivery_enabled      = var.enable_text_data
    video_data_delivery_enabled     = var.enable_video_data
    
    cloudwatch_config = {
      log_group_name = aws_cloudwatch_log_group.bedrock_logs.name
      role_arn      = aws_iam_role.bedrock_cloudwatch.arn
    }
  }
}
