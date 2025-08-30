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
  region = var.region
}

# Deploy the complete Bedrock solution
module "bedrock_solution" {
  source = "../../"

  environment = var.environment
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids

  # Network security configuration
  management_allowed_cidrs = var.management_allowed_cidrs
  runtime_allowed_cidrs    = var.runtime_allowed_cidrs
  vpc_cidr                 = var.vpc_cidr

  # Bedrock configuration
  bedrock_role_name = var.bedrock_role_name
  
  # Logging configuration
  log_retention_days = 90
  enable_s3_logging  = true
  s3_log_prefix      = "bedrock-invocations/"

  # Guardrails configuration
  enable_guardrails   = true
  pii_entities_action = "ANONYMIZE"
  
  content_filters = {
    sexual = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    violence = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    hate = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    insults = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    misconduct = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    prompt_attack = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
  }

  # Multi-region model access
  allowed_model_regions = ["us-east-1", "us-east-2", "us-west-2"]

  # VPC endpoint configuration
  enable_bedrock_management_endpoint     = true
  enable_bedrock_runtime_endpoint        = true
  enable_bedrock_agent_endpoint          = true
  enable_bedrock_agent_runtime_endpoint  = true

  # Model invocation logging
  enable_model_invocation_logging    = true
  enable_cloudwatch_logging          = true
  text_data_delivery_enabled         = true
  image_data_delivery_enabled        = true
  embedding_data_delivery_enabled    = true

  tags = merge(var.tags, {
    Example = "complete-bedrock-solution"
  })
}
