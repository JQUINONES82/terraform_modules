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

module "bedrock_guardrail" {
  source = "../../"

  name                      = var.guardrail_name
  blocked_input_messaging   = "Your input has been blocked due to policy violations."
  blocked_outputs_messaging = "The response has been blocked due to policy violations."
  description              = "Basic example of AWS Bedrock Guardrail"

  content_policy_config = {
    filters_config = [
      {
        input_strength  = "MEDIUM"
        output_strength = "MEDIUM"
        type           = "HATE"
      }
    ]
    tier_config = {
      tier_name = "STANDARD"
    }
  }

  tags = var.tags
}
