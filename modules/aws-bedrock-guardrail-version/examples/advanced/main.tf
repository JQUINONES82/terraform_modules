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

# Create a comprehensive guardrail
module "bedrock_guardrail" {
  source = "../../../aws-bedrock-guardrail"

  name                      = "${var.guardrail_name}-advanced"
  blocked_input_messaging   = "Your input has been blocked due to policy violations."
  blocked_outputs_messaging = "The response has been blocked due to policy violations."
  description              = "Advanced guardrail for multi-environment versioning"

  content_policy_config = {
    filters_config = [
      {
        input_strength  = "HIGH"
        output_strength = "HIGH"
        type           = "HATE"
      },
      {
        input_strength  = "MEDIUM"
        output_strength = "MEDIUM"
        type           = "VIOLENCE"
      }
    ]
    tier_config = {
      tier_name = "STANDARD"
    }
  }

  sensitive_information_policy_config = {
    pii_entities_config = [
      {
        action = "BLOCK"
        type   = "EMAIL"
      }
    ]
  }

  tags = var.tags
}

# Development version - not retained
module "guardrail_version_dev" {
  source = "../../"

  guardrail_arn = module.bedrock_guardrail.guardrail_arn
  description   = "Development version - ${var.dev_version_description}"
  skip_destroy  = false

  timeouts = {
    create = "8m"
    delete = "8m"
  }
}

# Staging version - retained for validation
module "guardrail_version_staging" {
  source = "../../"

  guardrail_arn = module.bedrock_guardrail.guardrail_arn
  description   = "Staging version - ${var.staging_version_description}"
  skip_destroy  = true

  timeouts = {
    create = "10m"
    delete = "10m"
  }
}

# Production version - always retained
module "guardrail_version_prod" {
  source = "../../"

  guardrail_arn = module.bedrock_guardrail.guardrail_arn
  description   = "Production version - ${var.prod_version_description}"
  skip_destroy  = true

  timeouts = {
    create = "15m"
    delete = "15m"
  }
}
