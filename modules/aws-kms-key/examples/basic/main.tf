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

# Basic KMS key
module "kms_key" {
  source = "../../"

  description         = "Basic KMS key for encryption"
  enable_key_rotation = true

  tags = {
    Name        = "basic-kms-key"
    Environment = "example"
    ManagedBy   = "terraform"
  }
}

# Output the key details
output "key_id" {
  description = "The KMS key ID"
  value       = module.kms_key.key_id
}

output "key_arn" {
  description = "The KMS key ARN"
  value       = module.kms_key.key_arn
}

output "enabled" {
  description = "Whether the key is enabled"
  value       = module.kms_key.enabled
}
