terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket for standard logging
resource "aws_s3_bucket" "bedrock_logs" {
  bucket        = "${var.bucket_name_prefix}-logs-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# S3 bucket for large data delivery
resource "aws_s3_bucket" "bedrock_large_data" {
  bucket        = "${var.bucket_name_prefix}-large-data-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# S3 bucket policies
resource "aws_s3_bucket_policy" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = ["s3:*"]
        Resource = [
          "${aws_s3_bucket.bedrock_logs.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "bedrock_large_data" {
  bucket = aws_s3_bucket.bedrock_large_data.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = ["s3:*"]
        Resource = [
          "${aws_s3_bucket.bedrock_large_data.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}

# CloudWatch log group
resource "aws_cloudwatch_log_group" "bedrock_logs" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days
}

# IAM role for CloudWatch access
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
}

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

# Hybrid logging configuration
module "bedrock_logging_hybrid" {
  source = "../../"
  
  depends_on = [
    aws_s3_bucket_policy.bedrock_logs,
    aws_s3_bucket_policy.bedrock_large_data
  ]

  logging_config = {
    embedding_data_delivery_enabled = var.enable_embedding_data
    image_data_delivery_enabled     = var.enable_image_data
    text_data_delivery_enabled      = var.enable_text_data
    video_data_delivery_enabled     = var.enable_video_data
    
    # S3 for long-term storage
    s3_config = {
      bucket_name = aws_s3_bucket.bedrock_logs.id
      key_prefix  = var.s3_key_prefix
    }
    
    # CloudWatch for real-time monitoring
    cloudwatch_config = {
      log_group_name = aws_cloudwatch_log_group.bedrock_logs.name
      role_arn      = aws_iam_role.bedrock_cloudwatch.arn
      
      # S3 for large data that exceeds CloudWatch limits
      large_data_delivery_s3_config = {
        bucket_name = aws_s3_bucket.bedrock_large_data.id
        key_prefix  = var.large_data_key_prefix
      }
    }
  }
}
