# AWS Budget Module

A comprehensive Terraform module for creating AWS Budgets with cost monitoring, spending limits, anomaly detection, and automated alerts.

## Features

- ✅ **Budget Management**: Create and manage AWS budgets with flexible configurations
- ✅ **Cost Monitoring**: Track spending across services, accounts, regions, and custom dimensions
- ✅ **Alert System**: Multi-threshold notifications via email and SNS
- ✅ **Anomaly Detection**: ML-powered cost anomaly detection and alerts
- ✅ **Flexible Filtering**: Comprehensive cost filtering by services, tags, accounts, regions
- ✅ **Auto-Adjustment**: Historical and forecast-based budget adjustments
- ✅ **CloudWatch Integration**: Additional CloudWatch alarms for enhanced monitoring
- ✅ **Multi-Account Support**: Organization and linked account budget management

## Usage

### Basic Budget

```hcl
module "monthly_budget" {
  source = "./modules/aws-budget"

  budget_name  = "monthly-spending-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = "1000"
  limit_unit   = "USD"

  notifications = [
    {
      comparison_operator   = "GREATER_THAN"
      threshold            = 80
      threshold_type       = "PERCENTAGE"
      notification_type    = "ACTUAL"
      subscriber_email_addresses = ["finance@company.com"]
    },
    {
      comparison_operator   = "GREATER_THAN"
      threshold            = 100
      threshold_type       = "PERCENTAGE"
      notification_type    = "FORECASTED"
      subscriber_email_addresses = ["cfo@company.com"]
    }
  ]

  tags = {
    Environment = "production"
    Owner      = "finance-team"
  }
}
```

### Service-Specific Budget

```hcl
module "bedrock_budget" {
  source = "./modules/aws-budget"

  budget_name  = "bedrock-ai-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = "500"

  # Filter for Bedrock services only
  cost_filters = {
    service = ["Amazon Bedrock"]
  }

  notifications = [
    {
      comparison_operator   = "GREATER_THAN"
      threshold            = 75
      threshold_type       = "PERCENTAGE"
      notification_type    = "ACTUAL"
      subscriber_email_addresses = ["ai-team@company.com"]
    }
  ]

  # Enable anomaly detection
  enable_anomaly_detection = true
  anomaly_threshold_value  = 50
  anomaly_subscriber_email_addresses = ["ai-team@company.com"]

  tags = {
    Project = "AI-Platform"
    Service = "Bedrock"
  }
}
```

### Multi-Service Budget with Complex Filtering

```hcl
module "compute_budget" {
  source = "./modules/aws-budget"

  budget_name  = "compute-services-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = "2000"

  # Filter for compute services
  cost_filters = {
    service = [
      "Amazon Elastic Compute Cloud - Compute",
      "Amazon Elastic Container Service",
      "AWS Lambda"
    ]
    region = ["us-east-1", "us-west-2"]
    tag = {
      Environment = ["production", "staging"]
      Team        = ["backend", "ml"]
    }
  }

  notifications = [
    {
      comparison_operator     = "GREATER_THAN"
      threshold              = 50
      threshold_type         = "PERCENTAGE"
      notification_type      = "ACTUAL"
      subscriber_email_addresses = ["ops-team@company.com"]
      subscriber_sns_topic_arns   = ["arn:aws:sns:us-east-1:123456789012:budget-alerts"]
    },
    {
      comparison_operator     = "GREATER_THAN"
      threshold              = 80
      threshold_type         = "PERCENTAGE"
      notification_type      = "FORECASTED"
      subscriber_email_addresses = ["finance@company.com"]
    }
  ]

  # Auto-adjust based on historical data
  auto_adjust_type = "HISTORICAL"
  historical_options_budget_adjustment_period = 6

  tags = {
    Department = "Engineering"
    Budget     = "compute-services"
  }
}
```

### Organizational Budget

```hcl
module "org_budget" {
  source = "./modules/aws-budget"

  budget_name  = "organization-total-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = "10000"

  # Include specific linked accounts
  cost_filters = {
    linked_account = [
      "123456789012",
      "123456789013",
      "123456789014"
    ]
  }

  notifications = [
    {
      comparison_operator     = "GREATER_THAN"
      threshold              = 85
      threshold_type         = "PERCENTAGE"
      notification_type      = "ACTUAL"
      subscriber_email_addresses = ["cfo@company.com", "finance-team@company.com"]
      subscriber_sns_topic_arns   = ["arn:aws:sns:us-east-1:123456789012:critical-budget-alerts"]
    }
  ]

  # Enable comprehensive anomaly detection
  enable_anomaly_detection = true
  anomaly_threshold_value  = 500
  anomaly_subscription_frequency = "IMMEDIATE"
  anomaly_subscriber_email_addresses = ["finance-alerts@company.com"]
  anomaly_subscriber_sns_topic_arns   = ["arn:aws:sns:us-east-1:123456789012:anomaly-alerts"]

  tags = {
    Scope       = "organization"
    Criticality = "high"
  }
}
```

### Usage-Based Budget

```hcl
module "s3_usage_budget" {
  source = "./modules/aws-budget"

  budget_name  = "s3-storage-usage"
  budget_type  = "USAGE"
  time_unit    = "MONTHLY"
  limit_amount = "1000"
  limit_unit   = "GB"

  cost_filters = {
    service     = ["Amazon Simple Storage Service"]
    usage_type  = ["TimedStorage-ByteHrs"]
  }

  notifications = [
    {
      comparison_operator   = "GREATER_THAN"
      threshold            = 90
      threshold_type       = "PERCENTAGE"
      notification_type    = "ACTUAL"
      subscriber_email_addresses = ["storage-team@company.com"]
    }
  ]

  tags = {
    Service = "S3"
    Type    = "usage-monitoring"
  }
}
```

## Configuration

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `budget_name` | `string` | Name of the budget |
| `limit_amount` | `string` | Budget limit amount |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `budget_type` | `string` | `"COST"` | Type of budget (COST, USAGE, RI_UTILIZATION, etc.) |
| `time_unit` | `string` | `"MONTHLY"` | Budget time unit (MONTHLY, QUARTERLY, ANNUALLY) |
| `limit_unit` | `string` | `"USD"` | Currency or unit for the budget |
| `cost_filters` | `object` | `{}` | Cost filters to apply |
| `notifications` | `list(object)` | `[]` | Notification configurations |
| `enable_anomaly_detection` | `bool` | `false` | Enable cost anomaly detection |
| `auto_adjust_type` | `string` | `null` | Auto-adjustment type (HISTORICAL, FORECAST) |

### Cost Filters

The module supports comprehensive cost filtering:

```hcl
cost_filters = {
  service           = ["Amazon Bedrock", "Amazon S3"]
  linked_account    = ["123456789012"]
  region           = ["us-east-1", "us-west-2"]
  availability_zone = ["us-east-1a", "us-east-1b"]
  instance_type    = ["t3.micro", "t3.small"]
  usage_type       = ["BoxUsage:t3.micro"]
  operating_system = ["Linux"]
  tenancy          = ["Shared"]
  record_type      = ["Usage"]
  
  tag = {
    Environment = ["production", "staging"]
    Team        = ["backend", "frontend"]
    Project     = ["web-app"]
  }
}
```

### Notification Types

```hcl
notifications = [
  {
    comparison_operator        = "GREATER_THAN"     # GREATER_THAN, LESS_THAN, EQUAL_TO
    threshold                 = 80                  # Threshold value
    threshold_type            = "PERCENTAGE"        # PERCENTAGE or ABSOLUTE_VALUE
    notification_type         = "ACTUAL"            # ACTUAL or FORECASTED
    subscriber_email_addresses = ["team@company.com"]
    subscriber_sns_topic_arns  = ["arn:aws:sns:..."]
  }
]
```

## Outputs

| Output | Description |
|--------|-------------|
| `budget_id` | The ID of the created budget |
| `budget_arn` | The ARN of the created budget |
| `budget_name` | The name of the created budget |
| `anomaly_detector_arn` | The ARN of the cost anomaly detector |
| `budget_summary` | Summary of budget configuration |
| `notification_configuration` | Summary of notification setup |

## Best Practices

### 1. Threshold Strategy
```hcl
notifications = [
  # Early warning
  {
    comparison_operator   = "GREATER_THAN"
    threshold            = 50
    threshold_type       = "PERCENTAGE"
    notification_type    = "ACTUAL"
    subscriber_email_addresses = ["team-lead@company.com"]
  },
  # Budget concern
  {
    comparison_operator   = "GREATER_THAN"
    threshold            = 80
    threshold_type       = "PERCENTAGE"
    notification_type    = "ACTUAL"
    subscriber_email_addresses = ["manager@company.com"]
  },
  # Budget exceeded forecast
  {
    comparison_operator   = "GREATER_THAN"
    threshold            = 100
    threshold_type       = "PERCENTAGE"
    notification_type    = "FORECASTED"
    subscriber_email_addresses = ["finance@company.com"]
  }
]
```

### 2. Service-Specific Monitoring
Create separate budgets for different service categories:

```hcl
# Compute services
module "compute_budget" {
  source = "./modules/aws-budget"
  # ... compute services config
}

# Storage services
module "storage_budget" {
  source = "./modules/aws-budget"
  # ... storage services config
}

# AI/ML services
module "ai_budget" {
  source = "./modules/aws-budget"
  # ... AI services config
}
```

### 3. Environment-Based Budgets
```hcl
module "production_budget" {
  source = "./modules/aws-budget"
  
  cost_filters = {
    tag = {
      Environment = ["production"]
    }
  }
  # ... config
}
```

### 4. Team/Project Budgets
```hcl
module "team_budget" {
  source = "./modules/aws-budget"
  
  cost_filters = {
    tag = {
      Team    = ["backend-team"]
      Project = ["web-application"]
    }
  }
  # ... config
}
```

## Integration with Bedrock Solution

To integrate with the Bedrock monitoring solution:

```hcl
# Bedrock-specific budget
module "bedrock_budget" {
  source = "./modules/aws-budget"

  budget_name  = "bedrock-ai-services"
  limit_amount = "1000"
  
  cost_filters = {
    service = ["Amazon Bedrock"]
  }

  notifications = [
    {
      comparison_operator     = "GREATER_THAN"
      threshold              = 75
      threshold_type         = "PERCENTAGE"
      notification_type      = "ACTUAL"
      # Use same SNS topics as Bedrock monitoring
      subscriber_sns_topic_arns = [module.bedrock_solution.cost_alerts_topic_arn]
    }
  ]

  enable_anomaly_detection = true
  anomaly_subscriber_sns_topic_arns = [module.bedrock_solution.cost_alerts_topic_arn]

  tags = var.tags
}
```

## Advanced Features

### Auto-Adjustment
Automatically adjust budgets based on historical data:

```hcl
auto_adjust_type = "HISTORICAL"
historical_options_budget_adjustment_period = 12  # Use last 12 months
```

### Anomaly Detection
Enable ML-powered cost anomaly detection:

```hcl
enable_anomaly_detection = true
anomaly_threshold_value  = 100  # Alert on $100+ anomalies
anomaly_subscription_frequency = "IMMEDIATE"
```

### CloudWatch Integration
The module automatically creates CloudWatch alarms for enhanced monitoring when SNS topics are configured.

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- AWS CLI configured with appropriate permissions

## Permissions

The module requires the following AWS permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "budgets:CreateBudget",
        "budgets:UpdateBudget",
        "budgets:DeleteBudget",
        "budgets:ViewBudget",
        "ce:CreateAnomalyDetector",
        "ce:CreateAnomalySubscription",
        "ce:UpdateAnomalyDetector",
        "ce:UpdateAnomalySubscription",
        "ce:DeleteAnomalyDetector",
        "ce:DeleteAnomalySubscription",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DeleteAlarms",
        "sns:Publish"
      ],
      "Resource": "*"
    }
  ]
}
```

## License

This module is released under the MIT License.
