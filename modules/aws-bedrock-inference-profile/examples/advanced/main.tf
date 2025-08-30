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

data "aws_caller_identity" "current" {}

# Development inference profile - Claude Haiku for cost optimization
module "dev_inference_profile" {
  source = "../../"

  name        = "${var.project_name}-dev-claude-haiku"
  description = "Development environment profile using Claude Haiku for cost optimization"

  model_source = {
    copy_from = "arn:aws:bedrock:${var.aws_region}::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
  }

  timeouts = {
    create = "8m"
    update = "6m"
    delete = "8m"
  }

  tags = merge(var.common_tags, {
    Environment = "development"
    ModelType   = "claude-haiku"
    CostTier    = "low"
  })
}

# Staging inference profile - Claude Sonnet for balanced performance
module "staging_inference_profile" {
  source = "../../"

  name        = "${var.project_name}-staging-claude-sonnet"
  description = "Staging environment profile using Claude Sonnet for balanced performance"

  model_source = {
    copy_from = "arn:aws:bedrock:${var.aws_region}::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0"
  }

  timeouts = {
    create = "10m"
    update = "8m"
    delete = "10m"
  }

  tags = merge(var.common_tags, {
    Environment = "staging"
    ModelType   = "claude-sonnet"
    CostTier    = "medium"
  })
}

# Production inference profile - Claude Opus for maximum performance
module "prod_inference_profile" {
  source = "../../"

  name        = "${var.project_name}-prod-claude-opus"
  description = "Production environment profile using Claude Opus for maximum performance"

  model_source = {
    copy_from = "arn:aws:bedrock:${var.aws_region}::foundation-model/anthropic.claude-3-opus-20240229-v1:0"
  }

  timeouts = {
    create = "15m"
    update = "12m"
    delete = "15m"
  }

  tags = merge(var.common_tags, {
    Environment = "production"
    ModelType   = "claude-opus"
    CostTier    = "high"
    Criticality = "mission-critical"
  })
}

# Cross-account inference profile example (if applicable)
module "cross_account_inference_profile" {
  source = "../../"
  count  = var.enable_cross_account_profile ? 1 : 0

  name        = "${var.project_name}-cross-account-profile"
  description = "Cross-account inference profile for shared AI services"

  model_source = {
    copy_from = "arn:aws:bedrock:${var.cross_account_region}:${var.cross_account_id}:inference-profile/${var.cross_account_profile_id}"
  }

  timeouts = {
    create = "12m"
    update = "10m"
    delete = "12m"
  }

  tags = merge(var.common_tags, {
    Environment    = "cross-account"
    SourceAccount  = var.cross_account_id
    SourceRegion   = var.cross_account_region
    CostTier      = "shared"
  })
}
