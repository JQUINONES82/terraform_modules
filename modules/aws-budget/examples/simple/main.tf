# Simple AWS Budget Example
# This example demonstrates basic budget configuration with email notifications

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Basic Monthly Budget
module "monthly_budget" {
  source = "../../"

  budget_name  = "monthly-spending-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.monthly_limit
  limit_unit   = "USD"

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 80
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.notification_email]
    },
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 100
      threshold_type            = "PERCENTAGE"
      notification_type         = "FORECASTED"
      subscriber_email_addresses = [var.notification_email]
    }
  ]

  tags = {
    Environment = var.environment
    Owner      = var.owner
    Purpose    = "cost-monitoring"
  }
}

# Bedrock-Specific Budget
module "bedrock_budget" {
  source = "../../"

  budget_name  = "bedrock-ai-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.bedrock_limit
  limit_unit   = "USD"

  cost_filters = {
    service = ["Amazon Bedrock"]
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 75
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.notification_email]
    }
  ]

  # Enable anomaly detection for Bedrock
  enable_anomaly_detection = true
  anomaly_threshold_value  = 50
  anomaly_subscriber_email_addresses = [var.notification_email]

  tags = {
    Service     = "Bedrock"
    Environment = var.environment
    Owner      = var.owner
  }
}
