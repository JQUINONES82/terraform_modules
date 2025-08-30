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

module "bedrock_inference_profile" {
  source = "../../"

  name        = var.profile_name
  description = var.profile_description

  model_source = {
    copy_from = var.model_arn
  }

  tags = var.tags
}
