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

# First create a guardrail
module "bedrock_guardrail" {
  source = "../../../aws-bedrock-guardrail"

  name                      = "${var.guardrail_name}-base"
  blocked_input_messaging   = "Your input has been blocked due to policy violations."
  blocked_outputs_messaging = "The response has been blocked due to policy violations."
  description              = "Base guardrail for version testing"

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

# Create a version of the guardrail
module "guardrail_version" {
  source = "../../"

  guardrail_arn = module.bedrock_guardrail.guardrail_arn
  description   = var.version_description
  skip_destroy  = var.skip_destroy
}
