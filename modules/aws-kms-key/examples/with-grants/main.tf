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

# Get current AWS account ID and caller identity
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create an IAM role for demonstration
resource "aws_iam_role" "example" {
  name = "kms-grant-example-role"

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
    Name = "KMS Grant Example Role"
  }
}

# KMS key with grants
module "kms_key_with_grants" {
  source = "../../"

  description         = "KMS key with access grants"
  enable_key_rotation = true

  enable_grants = true
  grants = {
    "lambda-encrypt-decrypt" = {
      grantee_principal = aws_iam_role.example.arn
      operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "DescribeKey"]
      constraints = {
        encryption_context_equals = {
          "Application" = "MyLambdaFunction"
          "Environment" = "Production"
        }
      }
    }
    "service-generate-datakey" = {
      grantee_principal  = aws_iam_role.example.arn
      operations         = ["GenerateDataKey", "GenerateDataKeyWithoutPlaintext"]
      retiring_principal = aws_iam_role.example.arn
    }
  }

  tags = {
    Name        = "grant-enabled-kms-key"
    Environment = "example"
    Purpose     = "grant-demonstration"
    ManagedBy   = "terraform"
  }
}

# Outputs
output "key_id" {
  description = "The KMS key ID"
  value       = module.kms_key_with_grants.key_id
}

output "key_arn" {
  description = "The KMS key ARN"
  value       = module.kms_key_with_grants.key_arn
}

output "grant_ids" {
  description = "Map of grant names to their IDs"
  value       = module.kms_key_with_grants.grant_ids
}

output "grant_tokens" {
  description = "Map of grant names to their tokens"
  value       = module.kms_key_with_grants.grant_tokens
}

output "example_role_arn" {
  description = "ARN of the example IAM role"
  value       = aws_iam_role.example.arn
}
