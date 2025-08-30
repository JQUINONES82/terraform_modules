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

# Variables for cross-account setup
variable "trusted_account_id" {
  description = "AWS account ID that can assume this role"
  type        = string
  default     = "123456789012"  # Replace with actual account ID
}

variable "external_id" {
  description = "External ID for additional security"
  type        = string
  default     = "unique-external-id-12345"
}

variable "permissions_boundary_arn" {
  description = "ARN of the permissions boundary policy"
  type        = string
  default     = null
}

module "cross_account_role" {
  source = "../../"

  name = "cross-account-example-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.trusted_account_id}:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
          IpAddress = {
            "aws:SourceIp" = [
              "203.0.113.0/24",  # Replace with your allowed IP ranges
              "198.51.100.0/24"
            ]
          }
        }
      }
    ]
  })

  description = "Cross-account role with permissions boundary and session limits"

  permissions_boundary = var.permissions_boundary_arn
  max_session_duration = 7200  # 2 hours

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  inline_policies = {
    limited_s3_access = {
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:ListBucket",
              "s3:GetObject"
            ]
            Resource = [
              "arn:aws:s3:::shared-resources-bucket",
              "arn:aws:s3:::shared-resources-bucket/*"
            ]
          }
        ]
      })
    }

    cloudwatch_logs_access = {
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:DescribeLogGroups",
              "logs:DescribeLogStreams"
            ]
            Resource = [
              "arn:aws:logs:*:*:log-group:/cross-account/*"
            ]
          }
        ]
      })
    }
  }

  force_detach_policies = true

  tags = {
    Environment   = "prod"
    Purpose       = "cross-account-access"
    TrustedAccount = var.trusted_account_id
    Example       = "cross-account"
  }
}
