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

# Create S3 bucket for Bedrock logging
resource "aws_s3_bucket" "bedrock_logs" {
  bucket        = "${var.bucket_name_prefix}-${random_id.bucket_suffix.hex}"
  force_destroy = true

  lifecycle {
    ignore_changes = [
      tags["CreatorId"], 
      tags["CreatorName"],
    ]
  }
}

# S3 bucket policy to allow Bedrock to write logs
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

# Configure Bedrock model invocation logging to S3
module "bedrock_logging" {
  source = "../../"
  
  depends_on = [aws_s3_bucket_policy.bedrock_logs]

  logging_config = {
    embedding_data_delivery_enabled = var.enable_embedding_data
    image_data_delivery_enabled     = var.enable_image_data
    text_data_delivery_enabled      = var.enable_text_data
    video_data_delivery_enabled     = var.enable_video_data
    
    s3_config = {
      bucket_name = aws_s3_bucket.bedrock_logs.id
      key_prefix  = var.s3_key_prefix
    }
  }
}
