# Complete Bedrock Management Runtime Example

This example demonstrates a complete deployment of the AWS Bedrock management runtime solution with all security features enabled.

## Overview

This example creates:
- Secure S3 buckets for logs and artifacts with encryption
- KMS keys for encryption at rest
- IAM roles and policies with least privilege access
- VPC endpoints for secure Bedrock access
- Security groups with network segmentation
- Bedrock guardrails for content filtering
- Comprehensive logging and monitoring
- Compliance-ready configuration

## Prerequisites

1. **AWS Account and Credentials**: Ensure you have AWS credentials configured
2. **VPC and Subnets**: You need an existing VPC and subnets where the solution will be deployed
3. **Terraform**: Version >= 1.0
4. **Permissions**: Your AWS credentials need permissions to create the required resources

## Required AWS Permissions

Your AWS user/role needs permissions for:
- IAM (roles, policies, attachments)
- S3 (buckets, bucket policies, encryption)
- KMS (keys, aliases, grants)
- VPC (endpoints, security groups, route tables)
- Bedrock (guardrails, model access, logging configuration)
- CloudTrail (trails, event data store)
- Logs (log groups, log streams)

## Usage

1. **Copy the example variables file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars** with your specific values:
   - Update `vpc_id` with your VPC ID
   - Update `subnet_ids` with your subnet IDs (minimum 2 for high availability)
   - Update `allowed_principals` with your AWS account/role ARNs
   - Customize other variables as needed

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Review the plan**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## Configuration Examples

### Minimal Configuration
```hcl
vpc_id     = "vpc-0123456789abcdef0"
subnet_ids = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
```

### Production Configuration
```hcl
environment  = "prod"
project_name = "bedrock-ai-platform"
vpc_id       = "vpc-0123456789abcdef0"
subnet_ids   = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]

allowed_principals = [
  "arn:aws:iam::123456789012:role/BedrockProdRole",
  "arn:aws:iam::123456789012:role/DataScienceTeam"
]

enable_guardrails               = true
enable_model_invocation_logging = true
enable_cloudtrail_logging       = true

compliance_framework  = "HIPAA"
data_residency_region = "us-east-1"
retention_days        = 365

tags = {
  "Environment"   = "prod"
  "Project"       = "ai-platform"
  "Owner"         = "AI Team"
  "CostCenter"    = "R&D"
  "Compliance"    = "HIPAA"
  "DataClass"     = "PHI"
}
```

## Security Features

This example demonstrates:

- **Encryption**: All data encrypted at rest and in transit
- **Network Security**: VPC endpoints and security groups for network isolation
- **Access Control**: IAM roles with least privilege and resource-based policies
- **Content Filtering**: Bedrock guardrails for PII detection and content moderation
- **Audit Logging**: Comprehensive logging of all API calls and model invocations
- **Compliance**: SOC2/HIPAA ready configuration

## Outputs

After deployment, you'll get outputs including:
- S3 bucket names and ARNs
- KMS key IDs and ARNs
- IAM role ARNs
- VPC endpoint IDs
- Guardrail ARNs
- Logging configuration details

## Cost Optimization

- S3 buckets include lifecycle policies for cost optimization
- CloudWatch logs have configurable retention periods
- VPC endpoints use policy-based access control to minimize costs
- KMS keys are regional to reduce cross-region charges

## Troubleshooting

### Common Issues

1. **VPC Endpoint Creation Fails**: Ensure your subnets are in different AZs
2. **IAM Permission Errors**: Verify your AWS credentials have sufficient permissions
3. **Bedrock Not Available**: Check if Bedrock is available in your chosen region

### Validation Commands

```bash
# Validate Terraform configuration
terraform validate

# Check resource status
terraform state list

# Verify S3 bucket encryption
aws s3api get-bucket-encryption --bucket <bucket-name>

# Test VPC endpoint connectivity
aws bedrock list-foundation-models --region <region>
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will permanently delete all created resources including any data stored in S3 buckets.
