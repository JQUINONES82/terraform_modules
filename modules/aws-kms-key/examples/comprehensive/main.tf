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

# Get current AWS account and region for policy
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Custom key policy
data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }
}

# Create IAM role for grants example
resource "aws_iam_role" "application_role" {
  name = "comprehensive-kms-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["lambda.amazonaws.com", "ec2.amazonaws.com"]
        }
      }
    ]
  })

  tags = {
    Name        = "Comprehensive KMS Application Role"
    Environment = "example"
  }
}

# Comprehensive KMS key with all features
module "comprehensive_kms_key" {
  source = "../../"

  description             = "Comprehensive KMS key with all features enabled"
  key_usage               = "ENCRYPT_DECRYPT"
  key_spec                = "SYMMETRIC_DEFAULT"
  policy                  = data.aws_iam_policy_document.kms_key_policy.json
  enable_key_rotation     = true
  rotation_period_in_days = 180
  multi_region            = false

  enable_alias  = true
  enable_grants = true

  aliases = {
    "comprehensive-app-key"    = "Primary comprehensive application key"
    "comprehensive-backup-key" = "Backup key for comprehensive app"
    "comprehensive-data-key"   = "Data encryption key"
  }

  grants = {
    "application-full-access" = {
      grantee_principal = aws_iam_role.application_role.arn
      operations = [
        "Encrypt",
        "Decrypt",
        "GenerateDataKey",
        "GenerateDataKeyWithoutPlaintext",
        "DescribeKey"
      ]
      constraints = {
        encryption_context_equals = {
          "Application" = "ComprehensiveApp"
          "Environment" = "Production"
        }
      }
      retiring_principal = aws_iam_role.application_role.arn
    }
    "monitoring-access" = {
      grantee_principal = aws_iam_role.application_role.arn
      operations        = ["DescribeKey", "GetKeyPolicy"]
    }
  }

  tags = {
    Name        = "comprehensive-kms-key"
    Environment = "example"
    Application = "comprehensive-demo"
    Purpose     = "all-features-demonstration"
    KeyRotation = "enabled"
    MultiRegion = "false"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }
}

# Outputs
output "key_id" {
  description = "The KMS key ID"
  value       = module.comprehensive_kms_key.key_id
}

output "key_arn" {
  description = "The KMS key ARN"
  value       = module.comprehensive_kms_key.key_arn
}

output "key_state" {
  description = "The KMS key state"
  value       = module.comprehensive_kms_key.enabled
}

output "key_usage" {
  description = "The KMS key usage"
  value       = module.comprehensive_kms_key.key_usage
}

output "enable_key_rotation" {
  description = "Whether key rotation is enabled"
  value       = module.comprehensive_kms_key.enable_key_rotation
}

output "alias_names" {
  description = "Map of alias names and their details"
  value       = module.comprehensive_kms_key.alias_names
}

output "alias_arns" {
  description = "Map of alias ARNs"
  value       = module.comprehensive_kms_key.alias_arns
}

output "grant_ids" {
  description = "Map of grant names to their IDs"
  value       = module.comprehensive_kms_key.grant_ids
}

output "grant_tokens" {
  description = "Map of grant names to their tokens"
  value       = module.comprehensive_kms_key.grant_tokens
  sensitive   = true
}

output "application_role_arn" {
  description = "ARN of the application IAM role"
  value       = aws_iam_role.application_role.arn
}
