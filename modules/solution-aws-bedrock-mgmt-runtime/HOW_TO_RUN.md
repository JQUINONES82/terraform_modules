# How to Run the AWS Bedrock Management Runtime Solution

This guide provides step-by-step instructions for deploying the complete AWS Bedrock Management Runtime solution with comprehensive monitoring, alerting, and budget controls.

## Prerequisites

### 1. **AWS Account Setup**
- AWS account with appropriate permissions
- AWS CLI configured with credentials
- Terraform >= 1.0 installed
- PowerShell (Windows) or Bash (Linux/Mac)

### 2. **Required AWS Permissions**
Your AWS credentials need permissions for:
```
- AWS Bedrock (all actions)
- AWS Budgets (create, modify budgets)
- AWS Cost Explorer (anomaly detection)
- CloudWatch (alarms, logs)
- SNS (topics, subscriptions)
- KMS (key creation, usage)
- S3 (bucket creation, policies)
- IAM (role creation, policies)
- VPC (endpoints, security groups)
- Cost and Billing (budget notifications)
```

### 3. **Infrastructure Requirements**
- Existing VPC with private subnets
- Internet connectivity for Terraform downloads
- DNS resolution for AWS services

## Step 1: Prepare Your Environment

### 1.1 Clone or Navigate to the Module
```bash
cd D:\G\terraform_modules\modules\solution-aws-bedrock-mgmt-runtime
```

### 1.2 Verify Module Structure
```bash
# Should see these key files:
ls
# main.tf
# variables.tf  
# outputs.tf
# README.md
# BUDGET_IMPLEMENTATION_SUMMARY.md
# examples/complete/
```

### 1.3 Review the Solution Components
```bash
# Check the complete example
cd examples/complete
ls
# main.tf
# variables.tf
# outputs.tf  
# terraform.tfvars.example
# README.md
```

## Step 2: Configure Your Deployment

### 2.1 Copy Example Configuration
```bash
# In examples/complete directory
cp terraform.tfvars.example terraform.tfvars
```

### 2.2 Edit Configuration File
```bash
# Edit terraform.tfvars with your specific values
notepad terraform.tfvars  # Windows
# OR
nano terraform.tfvars     # Linux/Mac
```

### 2.3 Required Configuration Updates

#### **Infrastructure Settings**
```hcl
# Replace with your actual VPC and subnet IDs
vpc_id = "vpc-0123456789abcdef0"  # Your VPC ID
subnet_ids = [
  "subnet-0123456789abcdef0",     # Your private subnet IDs
  "subnet-0fedcba9876543210"
]

# Set your environment
environment = "production"  # or "dev", "staging"
```

#### **Budget Configuration (Key Section)**
```hcl
# Budget control
enable_budget_monitoring       = true
enable_token_budget_monitoring = true

# Budget limits
bedrock_monthly_budget_limit = "1000"    # $1,000 USD monthly limit
token_monthly_budget_limit   = "1000000" # 1M token monthly limit

# Email configuration - UPDATE THESE!
budget_notification_email = "your-email@company.com"  # Replace with your email

# Multiple notification emails for different alert types
budget_notification_emails = ["your-email@company.com"]
budget_warning_emails     = ["your-email@company.com"]                    # 50% threshold
budget_critical_emails    = ["your-email@company.com", "admin@company.com"] # 80% threshold  
budget_forecast_emails    = ["your-email@company.com", "finance@company.com"] # 100% forecast

# Budget thresholds (percentages)
budget_warning_threshold  = 50   # Early warning at 50%
budget_critical_threshold = 80   # Critical alert at 80%
budget_forecast_threshold = 100  # Forecast alert at 100%
```

#### **Security Settings**
```hcl
# Update with your AWS account ID
allowed_principals = [
  "arn:aws:iam::YOUR-ACCOUNT-ID:root",        # Replace YOUR-ACCOUNT-ID
  "arn:aws:iam::YOUR-ACCOUNT-ID:role/YourRole" # Optional: specific roles
]

# Network access (adjust CIDR blocks as needed)
management_allowed_cidrs = ["10.0.0.0/8"]  # Your management network
runtime_allowed_cidrs    = ["10.0.0.0/8"]  # Your application network
vpc_cidr                = "10.0.0.0/16"    # Your VPC CIDR
```

#### **Monitoring Configuration**
```hcl
# Enable all monitoring features
enable_alerting                          = true
enable_anomaly_detection                 = true
enable_composite_alarms                  = true
enable_cost_alerting                     = true
enable_token_monitoring                  = true

# Service-specific monitoring
enable_agents_monitoring                 = true
enable_knowledge_base_monitoring         = true
enable_guardrails_monitoring             = true
enable_training_monitoring               = true
enable_api_call_monitoring               = true
enable_comprehensive_health_monitoring   = true
```

#### **Resource Tags**
```hcl
tags = {
  "Terraform"     = "true"
  "Environment"   = "production"
  "Project"       = "bedrock-mgmt-runtime"
  "Owner"         = "Your Team"
  "CostCenter"    = "Engineering"
  "Email"         = "your-email@company.com"
}
```

## Step 3: Initialize and Validate

### 3.1 Initialize Terraform
```bash
# In examples/complete directory
terraform init
```

**Expected Output:**
```
Initializing modules...
- bedrock_solution in ../../

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching ">= 5.0"...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

### 3.2 Validate Configuration
```bash
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

### 3.3 Format Configuration
```bash
terraform fmt
```

## Step 4: Plan the Deployment

### 4.1 Run Terraform Plan
```bash
terraform plan -out=bedrock-solution.tfplan
```

### 4.2 Review Plan Output
Look for these key resources being created:

#### **Core Infrastructure:**
```
# module.bedrock_solution.module.bedrock_kms_key
# module.bedrock_solution.module.bedrock_logs_bucket  
# module.bedrock_solution.module.bedrock_logging_role
# module.bedrock_solution.module.bedrock_management_sg
# module.bedrock_solution.module.bedrock_runtime_sg
```

#### **VPC Endpoints:**
```
# module.bedrock_solution.module.bedrock_management_endpoint
# module.bedrock_solution.module.bedrock_runtime_endpoint
# module.bedrock_solution.module.bedrock_agent_endpoint
# module.bedrock_solution.module.bedrock_agent_runtime_endpoint
```

#### **Monitoring & Alerting:**
```
# module.bedrock_solution.module.bedrock_critical_alerts
# module.bedrock_solution.module.bedrock_performance_alerts
# module.bedrock_solution.module.bedrock_cost_alerts
# module.bedrock_solution.module.bedrock_invocation_errors_alarm
# ... (many CloudWatch alarms)
```

#### **Budget Resources:**
```
# module.bedrock_solution.module.bedrock_cost_budget[0]
# module.bedrock_solution.module.bedrock_token_budget[0]
```

### 4.3 Verify Resource Count
```bash
# Should show something like:
Plan: 45 to add, 0 to change, 0 to destroy.
```

## Step 5: Deploy the Solution

### 5.1 Apply the Configuration
```bash
terraform apply bedrock-solution.tfplan
```

### 5.2 Confirm Deployment
When prompted, type `yes` to confirm:
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

### 5.3 Monitor Deployment Progress
The deployment will take approximately 5-10 minutes. You'll see resources being created:

```
module.bedrock_solution.module.bedrock_kms_key.aws_kms_key.this: Creating...
module.bedrock_solution.module.bedrock_logs_bucket.aws_s3_bucket.this: Creating...
...
module.bedrock_solution.module.bedrock_cost_budget[0].aws_budgets_budget.this[0]: Creating...
...
Apply complete! Resources: 45 added, 0 changed, 0 destroyed.
```

## Step 6: Post-Deployment Configuration

### 6.1 Confirm SNS Subscriptions

#### Check Your Email
After deployment, you'll receive SNS subscription confirmation emails for:
- Budget warning notifications (50% threshold)
- Budget critical notifications (80% threshold)  
- Budget forecast notifications (100% threshold)
- Cost anomaly detection alerts
- Token usage anomaly alerts

#### Confirm Each Subscription
1. Check your email inbox (and spam folder)
2. Click "Confirm subscription" link in each email
3. You should see "Subscription confirmed!" message

### 6.2 Verify Budget Creation

#### AWS Console Method
1. Log into AWS Console
2. Navigate to **AWS Budgets** service
3. You should see:
   - `bedrock-ai-services-budget-{environment}`
   - `bedrock-token-usage-budget-{environment}`

#### CLI Method
```bash
aws budgets describe-budgets --account-id $(aws sts get-caller-identity --query Account --output text)
```

### 6.3 Verify CloudWatch Alarms

#### AWS Console Method
1. Navigate to **CloudWatch > Alarms**
2. You should see multiple alarms with names starting with:
   - `bedrock-invocation-errors-`
   - `bedrock-latency-`
   - `bedrock-throttle-`
   - etc.

#### CLI Method
```bash
aws cloudwatch describe-alarms --alarm-name-prefix bedrock
```

## Step 7: Test the Solution

### 7.1 View Deployment Outputs
```bash
terraform output
```

**Expected Outputs:**
```
bedrock_cost_budget_arn = "arn:aws:budgets::123456789012:budget/bedrock-ai-services-budget-production"
bedrock_cost_budget_name = "bedrock-ai-services-budget-production"
budget_configuration_summary = {
  "cost_budget_enabled" = true
  "cost_budget_limit" = "1000"
  "notification_emails" = ["your-email@company.com"]
  "warning_threshold" = 50
  # ... more details
}
kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
# ... more outputs
```

### 7.2 Test Budget Notifications (Optional)

#### Create Test Spend
If you want to test the budget alerts, you can:
1. Use AWS Cost Explorer to view current Bedrock costs
2. Set a lower budget threshold temporarily for testing
3. Generate some Bedrock API calls to accumulate costs

#### Modify Test Budget
```bash
# Create a test budget with $10 limit for quick testing
cat > test-budget.tf << EOF
module "test_budget" {
  source = "../../modules/aws-budget"
  
  budget_name  = "test-bedrock-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = "10"
  limit_unit   = "USD"
  
  cost_filters = {
    service = ["Amazon Bedrock"]
  }
  
  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 50
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = ["your-email@company.com"]
    }
  ]
  
  tags = {
    Purpose = "testing"
  }
}
EOF

terraform plan
terraform apply
```

### 7.3 Test Bedrock Access

#### Test VPC Endpoint Connectivity
```bash
# Test from an EC2 instance in your VPC
nslookup bedrock-runtime.us-east-1.amazonaws.com

# Should resolve to private IP addresses in your VPC
```

#### Test Bedrock API (if you have access)
```bash
# Example CLI test (requires appropriate IAM permissions)
aws bedrock list-foundation-models
```

## Step 8: Monitoring and Maintenance

### 8.1 Monitor Budget Status

#### AWS Console
1. Go to **AWS Budgets**
2. Click on your budget name
3. View current vs. forecasted spend
4. Check alert history

#### CloudWatch Dashboard
1. Navigate to **CloudWatch > Dashboards**
2. Create custom dashboard with budget metrics
3. Add widgets for:
   - Estimated charges
   - Budget utilization
   - Alarm states

### 8.2 Monitor Solution Health

#### Check Alarm States
```bash
# View all alarm states
aws cloudwatch describe-alarms --query 'MetricAlarms[?starts_with(AlarmName, `bedrock`)].{Name:AlarmName,State:StateValue}' --output table
```

#### Review CloudWatch Logs
```bash
# List log groups
aws logs describe-log-groups --log-group-name-prefix "/aws/bedrock"
```

### 8.3 Adjust Budget Thresholds

If you need to modify budget settings after deployment:

```bash
# Edit terraform.tfvars
notepad terraform.tfvars

# Update budget limits or email addresses
bedrock_monthly_budget_limit = "2000"  # Increase to $2,000
budget_critical_emails = [
  "your-email@company.com",
  "new-admin@company.com"
]

# Apply changes
terraform plan
terraform apply
```

## Step 9: Troubleshooting

### 9.1 Common Issues

#### **Issue: SNS Subscription Not Confirmed**
```bash
# Check SNS subscription status
aws sns list-subscriptions-by-topic --topic-arn $(terraform output -raw bedrock_cost_alerts_topic_arn)

# Look for PendingConfirmation status
# Solution: Check email and confirm subscription
```

#### **Issue: Budget Not Triggering Alerts**
```bash
# Check budget configuration
aws budgets describe-budget --account-id $(aws sts get-caller-identity --query Account --output text) --budget-name $(terraform output -raw bedrock_cost_budget_name)

# Verify notification settings and thresholds
```

#### **Issue: CloudWatch Alarms in INSUFFICIENT_DATA State**
```bash
# Check if Bedrock is generating metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Bedrock \
  --metric-name Invocations \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 3600 \
  --statistics Sum

# Note: Metrics only appear when Bedrock is actively used
```

#### **Issue: VPC Endpoint Connection Failures**
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids $(terraform output -raw management_security_group_id)

# Verify endpoint status
aws ec2 describe-vpc-endpoints --filters Name=service-name,Values=com.amazonaws.us-east-1.bedrock
```

### 9.2 Validation Commands

#### **Validate Complete Deployment**
```bash
# Run this script to validate everything is working
cat > validate-deployment.sh << 'EOF'
#!/bin/bash

echo "=== Bedrock Solution Validation ==="

# Check Terraform state
echo "1. Checking Terraform state..."
terraform show -json | jq '.values.root_module.child_modules | length'

# Check budgets
echo "2. Checking budgets..."
aws budgets describe-budgets --account-id $(aws sts get-caller-identity --query Account --output text) --query 'Budgets[?starts_with(BudgetName, `bedrock`)].BudgetName'

# Check CloudWatch alarms
echo "3. Checking CloudWatch alarms..."
aws cloudwatch describe-alarms --alarm-name-prefix bedrock --query 'MetricAlarms | length'

# Check SNS topics
echo "4. Checking SNS topics..."
aws sns list-topics --query 'Topics[?contains(TopicArn, `bedrock`)].TopicArn'

# Check KMS key
echo "5. Checking KMS key..."
aws kms describe-key --key-id $(terraform output -raw kms_key_id) --query 'KeyMetadata.KeyState'

echo "=== Validation Complete ==="
EOF

chmod +x validate-deployment.sh
./validate-deployment.sh
```

## Step 10: Cleanup (Optional)

### 10.1 Destroy Resources
```bash
# If you need to tear down the solution
terraform plan -destroy
terraform destroy

# Confirm with 'yes' when prompted
```

### 10.2 Manual Cleanup
Some resources may need manual cleanup:
- S3 bucket contents (if any logs were created)
- CloudWatch log groups (if retention is longer than expected)
- SNS subscription confirmations (automatic cleanup)

## Cost Considerations

### Expected Monthly Costs
- **AWS Budgets**: Free (up to 62 budgets)
- **SNS Notifications**: ~$0.50 per million notifications (~$1/month typical)
- **CloudWatch Alarms**: ~$0.10 per alarm per month (~$5/month for 50 alarms)
- **CloudWatch Logs**: Based on ingestion (~$0.50/GB)
- **KMS**: ~$1/month per key
- **VPC Endpoints**: ~$7.30/month per endpoint (~$30/month total)
- **S3 Storage**: ~$0.023/GB per month

**Total Estimated Cost**: ~$40-50/month for the monitoring infrastructure (excluding actual Bedrock usage costs)

## Security Best Practices

1. **Least Privilege**: IAM roles use minimal required permissions
2. **Encryption**: All data encrypted at rest and in transit
3. **Network Isolation**: VPC endpoints prevent internet egress
4. **Monitoring**: Comprehensive alerting on all security events
5. **Compliance**: SOC2/HIPAA ready configuration

## Next Steps

1. **Create Runbooks**: Document incident response procedures
2. **Set Up Dashboards**: Create CloudWatch dashboards for monitoring
3. **Tune Alerts**: Adjust thresholds based on actual usage patterns
4. **Integrate with Tools**: Connect SNS to PagerDuty, Slack, etc.
5. **Regular Reviews**: Monthly review of costs and alert effectiveness

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review AWS documentation for specific services
3. Check Terraform AWS provider documentation
4. Review the `BUDGET_IMPLEMENTATION_SUMMARY.md` file for detailed configuration options

---

## Quick Reference

### Key Files
- `terraform.tfvars` - Your configuration
- `main.tf` - Solution definition
- `outputs.tf` - Solution outputs
- `BUDGET_IMPLEMENTATION_SUMMARY.md` - Detailed budget documentation

### Key Commands
```bash
terraform init      # Initialize
terraform plan      # Preview changes
terraform apply     # Deploy
terraform output    # View outputs
terraform destroy   # Cleanup
```

### Key AWS Services
- **AWS Budgets** - Cost monitoring
- **Amazon Bedrock** - AI/ML foundation models
- **CloudWatch** - Monitoring and alerting
- **SNS** - Notifications
- **KMS** - Encryption
- **VPC Endpoints** - Private connectivity

This completes the end-to-end deployment guide for the AWS Bedrock Management Runtime solution with comprehensive budget monitoring and alerting capabilities.
