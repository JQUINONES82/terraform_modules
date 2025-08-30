# Complete AWS Budget Example

This example demonstrates a comprehensive budget configuration for an enterprise AWS environment, including multiple budget types, cost filters, anomaly detection, and team-specific notifications.

## Architecture

The example creates 8 different budgets:

1. **Total Account Budget** - Overall account spending limit with anomaly detection
2. **AI/ML Services Budget** - Dedicated budget for AI services including Bedrock
3. **Compute Services Budget** - EC2, ECS, Lambda, and Fargate monitoring
4. **Storage Services Budget** - S3, EBS, and EFS cost tracking
5. **Database Services Budget** - RDS, DynamoDB, and ElastiCache monitoring
6. **Development Environment Budget** - Resources tagged as development
7. **Production Environment Budget** - Production resources with critical alerting
8. **EC2 Usage Budget** - Usage-based tracking for EC2 instance hours

## Features Demonstrated

### Multi-Tier Alerting
- **50%** threshold: Early warning to team leads
- **80%** threshold: Alert managers and finance
- **100%** forecasted: Critical alert to finance team

### Service-Specific Monitoring
Each major service category has dedicated budgets with appropriate thresholds and team notifications.

### Environment-Based Budgets
Separate tracking for development and production environments using tag-based filtering.

### Anomaly Detection
Enabled for critical budgets (account-wide, AI services, production) with immediate notifications.

### Team-Specific Notifications
Different teams receive relevant alerts:
- AI team gets AI services alerts
- Ops team gets compute and production alerts
- Finance team gets high-level budget alerts

## Deployment

1. **Copy the example files:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Customize the variables:**
   Edit `terraform.tfvars` with your specific:
   - Budget limits
   - Email addresses
   - AWS regions
   - Tag values

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Cost Considerations

- **Budgets**: No cost for AWS Budgets (up to 62 budgets)
- **SNS**: ~$0.50 per million notifications
- **Anomaly Detection**: No additional cost for AWS Cost Anomaly Detection

## Integration with Other Systems

The budgets can be integrated with:

### Bedrock Solution
```hcl
# In your Bedrock module configuration
module "bedrock_solution" {
  source = "../../solution-aws-bedrock-mgmt-runtime"
  
  # Use budget alerts SNS topic
  cost_alert_subscriptions = {
    "budget-integration" = {
      protocol = "sns"
      endpoint = module.budget_example.budget_alerts_topic_arn
    }
  }
}
```

### CloudWatch Dashboards
Use the budget ARNs to create custom dashboards:

```hcl
resource "aws_cloudwatch_dashboard" "cost_monitoring" {
  dashboard_name = "cost-monitoring"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        properties = {
          metrics = [
            ["AWS/Budgets", "ActualSpend", "BudgetName", module.account_budget.budget_name],
            ["AWS/Budgets", "ForecastedSpend", "BudgetName", module.account_budget.budget_name]
          ]
          period = 86400
          stat   = "Average"
          region = var.aws_region
          title  = "Account Budget Status"
        }
      }
    ]
  })
}
```

### Cost Optimization Automation
Use budget alerts to trigger cost optimization actions:

```hcl
resource "aws_lambda_function" "cost_optimizer" {
  # Lambda function that responds to budget alerts
  # Can stop non-production resources, send detailed reports, etc.
}

resource "aws_sns_topic_subscription" "cost_optimizer" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.cost_optimizer.arn
}
```

## Monitoring and Alerts

### Email Notifications
The example configures email notifications for different teams:
- Operations team gets compute and infrastructure alerts
- AI team gets AI services alerts
- Finance team gets high-level budget alerts
- Development team gets dev environment alerts

### SNS Integration
All budgets use a central SNS topic that can be integrated with:
- PagerDuty for on-call alerting
- Slack for team notifications
- Lambda functions for automated responses
- CloudWatch for additional monitoring

### Anomaly Detection
Three budgets have anomaly detection enabled:
- Account-wide anomaly detection with $200 threshold
- AI services anomaly detection with $100 threshold
- Production environment anomaly detection with $200 threshold

## Customization

### Adding New Service Categories
To add a new service category budget:

```hcl
module "networking_budget" {
  source = "../../"

  budget_name  = "networking-services-budget-${var.environment}"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = "300"

  cost_filters = {
    service = [
      "Amazon CloudFront",
      "Amazon Route 53",
      "AWS Direct Connect",
      "Elastic Load Balancing"
    ]
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 80
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.networking_team_email]
    }
  ]

  tags = merge(var.tags, {
    BudgetType = "networking-services"
    Team       = "networking"
  })
}
```

### Project-Specific Budgets
Add project-specific budgets using tag filtering:

```hcl
module "project_x_budget" {
  source = "../../"

  budget_name  = "project-x-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = "1000"

  cost_filters = {
    tag = {
      Project = ["project-x"]
    }
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 75
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = ["project-x-lead@company.com"]
    }
  ]

  tags = merge(var.tags, {
    BudgetType = "project-specific"
    Project    = "project-x"
  })
}
```

## Best Practices Demonstrated

1. **Hierarchical Budgets**: Account → Service Category → Environment
2. **Team Ownership**: Appropriate teams get relevant alerts
3. **Multiple Thresholds**: Progressive alerting (50%, 80%, 100%)
4. **Anomaly Detection**: Critical budgets have ML-powered anomaly detection
5. **Tagging Strategy**: Consistent tagging for cost allocation
6. **Environment Separation**: Dev and prod have separate budgets
7. **Usage Tracking**: EC2 hours tracked separately from costs
8. **Automation Ready**: SNS topics enable automated responses

This example provides a production-ready foundation for comprehensive AWS cost management and can be easily extended for additional services, projects, or organizational requirements.
