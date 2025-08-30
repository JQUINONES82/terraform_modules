# Complete AWS Budget Example
# This example demonstrates comprehensive budget configuration with multiple
# budgets, cost filters, anomaly detection, and integration with SNS

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

# Create SNS topic for budget alerts
resource "aws_sns_topic" "budget_alerts" {
  name              = "budget-alerts-${var.environment}"
  kms_master_key_id = "alias/aws/sns"
  
  tags = var.tags
}

resource "aws_sns_topic_subscription" "budget_email" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# Overall Account Budget
module "account_budget" {
  source = "../../"

  budget_name  = "total-account-budget-${var.environment}"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.total_budget_limit
  limit_unit   = "USD"

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 50
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.notification_email]
      subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
    },
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 80
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.notification_email, var.finance_email]
      subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
    },
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 100
      threshold_type            = "PERCENTAGE"
      notification_type         = "FORECASTED"
      subscriber_email_addresses = [var.finance_email]
      subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
    }
  ]

  # Enable anomaly detection for overall account
  enable_anomaly_detection = true
  anomaly_threshold_value  = var.anomaly_threshold
  anomaly_subscription_frequency = "DAILY"
  anomaly_subscriber_email_addresses = [var.notification_email]
  anomaly_subscriber_sns_topic_arns   = [aws_sns_topic.budget_alerts.arn]

  # Auto-adjust based on historical data
  auto_adjust_type = "HISTORICAL"
  historical_options_budget_adjustment_period = 6

  tags = merge(var.tags, {
    BudgetType = "total-account"
    Scope      = "account-wide"
  })
}

# AI/ML Services Budget (including Bedrock)
module "ai_services_budget" {
  source = "../../"

  budget_name  = "ai-ml-services-budget-${var.environment}"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.ai_services_budget_limit
  limit_unit   = "USD"

  cost_filters = {
    service = [
      "Amazon Bedrock",
      "Amazon SageMaker",
      "Amazon Comprehend",
      "Amazon Textract",
      "Amazon Rekognition",
      "Amazon Translate",
      "Amazon Transcribe",
      "Amazon Polly",
      "Amazon Lex",
      "AWS DeepLens"
    ]
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 75
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.ai_team_email]
      subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
    },
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 90
      threshold_type            = "PERCENTAGE"
      notification_type         = "FORECASTED"
      subscriber_email_addresses = [var.ai_team_email, var.finance_email]
      subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
    }
  ]

  # Enable anomaly detection for AI services
  enable_anomaly_detection = true
  anomaly_threshold_value  = 100
  anomaly_subscription_frequency = "IMMEDIATE"
  anomaly_subscriber_email_addresses = [var.ai_team_email]

  tags = merge(var.tags, {
    BudgetType = "ai-services"
    Team       = "ai-ml"
  })
}

# Compute Services Budget
module "compute_budget" {
  source = "../../"

  budget_name  = "compute-services-budget-${var.environment}"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.compute_budget_limit
  limit_unit   = "USD"

  cost_filters = {
    service = [
      "Amazon Elastic Compute Cloud - Compute",
      "Amazon Elastic Container Service",
      "AWS Lambda",
      "AWS Fargate"
    ]
    region = var.allowed_regions
    tag = {
      Environment = [var.environment]
    }
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 70
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.ops_team_email]
    },
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 85
      threshold_type            = "PERCENTAGE"
      notification_type         = "FORECASTED"
      subscriber_email_addresses = [var.ops_team_email, var.finance_email]
    }
  ]

  tags = merge(var.tags, {
    BudgetType = "compute-services"
    Team       = "infrastructure"
  })
}

# Storage Services Budget
module "storage_budget" {
  source = "../../"

  budget_name  = "storage-services-budget-${var.environment}"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.storage_budget_limit
  limit_unit   = "USD"

  cost_filters = {
    service = [
      "Amazon Simple Storage Service",
      "Amazon Elastic Block Store",
      "Amazon Elastic File System"
    ]
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 80
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.storage_team_email]
    }
  ]

  tags = merge(var.tags, {
    BudgetType = "storage-services"
    Team       = "infrastructure"
  })
}

# Database Services Budget
module "database_budget" {
  source = "../../"

  budget_name  = "database-services-budget-${var.environment}"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.database_budget_limit
  limit_unit   = "USD"

  cost_filters = {
    service = [
      "Amazon Relational Database Service",
      "Amazon DynamoDB",
      "Amazon ElastiCache",
      "Amazon DocumentDB (with MongoDB compatibility)",
      "Amazon Neptune"
    ]
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 75
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.database_team_email]
    }
  ]

  tags = merge(var.tags, {
    BudgetType = "database-services"
    Team       = "database"
  })
}

# Development Environment Budget
module "dev_environment_budget" {
  source = "../../"

  budget_name  = "development-environment-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.dev_environment_limit
  limit_unit   = "USD"

  cost_filters = {
    tag = {
      Environment = ["development", "dev", "sandbox"]
    }
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 90
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.dev_team_email]
    }
  ]

  tags = merge(var.tags, {
    BudgetType  = "development-environment"
    Environment = "development"
  })
}

# Production Environment Budget
module "prod_environment_budget" {
  source = "../../"

  budget_name  = "production-environment-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.prod_environment_limit
  limit_unit   = "USD"

  cost_filters = {
    tag = {
      Environment = ["production", "prod"]
    }
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 60
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.ops_team_email]
    },
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 85
      threshold_type            = "PERCENTAGE"
      notification_type         = "FORECASTED"
      subscriber_email_addresses = [var.ops_team_email, var.finance_email]
    }
  ]

  # Enable anomaly detection for production
  enable_anomaly_detection = true
  anomaly_threshold_value  = 200
  anomaly_subscription_frequency = "IMMEDIATE"
  anomaly_subscriber_email_addresses = [var.ops_team_email]

  tags = merge(var.tags, {
    BudgetType  = "production-environment"
    Environment = "production"
    Criticality = "high"
  })
}

# EC2 Usage Budget (Track instance hours)
module "ec2_usage_budget" {
  source = "../../"

  budget_name  = "ec2-usage-hours-budget-${var.environment}"
  budget_type  = "USAGE"
  time_unit    = "MONTHLY"
  limit_amount = var.ec2_usage_hours_limit
  limit_unit   = "Hrs"

  cost_filters = {
    service    = ["Amazon Elastic Compute Cloud - Compute"]
    usage_type = ["BoxUsage:t3.micro", "BoxUsage:t3.small", "BoxUsage:t3.medium"]
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 80
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.ops_team_email]
    }
  ]

  tags = merge(var.tags, {
    BudgetType = "usage-tracking"
    Service    = "ec2"
  })
}
