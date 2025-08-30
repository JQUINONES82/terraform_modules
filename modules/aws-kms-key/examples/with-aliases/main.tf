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

# KMS key with aliases
module "kms_key_with_aliases" {
  source = "../../"

  description             = "KMS key with multiple aliases"
  enable_key_rotation     = true
  rotation_period_in_days = 90

  enable_alias = true
  aliases = {
    "my-app-primary"      = "Primary application key"
    "my-app-backup"       = "Backup key alias"
    "database-encryption" = "Database encryption key"
  }

  tags = {
    Name        = "aliased-kms-key"
    Environment = "example"
    Application = "my-application"
    ManagedBy   = "terraform"
  }
}

# Output the key and alias details
output "key_id" {
  description = "The KMS key ID"
  value       = module.kms_key_with_aliases.key_id
}

output "key_arn" {
  description = "The KMS key ARN"
  value       = module.kms_key_with_aliases.key_arn
}

output "alias_names" {
  description = "Map of alias names and their details"
  value       = module.kms_key_with_aliases.alias_names
}

output "alias_arns" {
  description = "Map of alias ARNs"
  value       = module.kms_key_with_aliases.alias_arns
}
