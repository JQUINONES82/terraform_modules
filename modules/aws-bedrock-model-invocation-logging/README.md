# AWS Bedrock Model Invocation Logging Configuration Module

This module provides a Terraform resource for managing Amazon Bedrock model invocation logging configuration, which enables comprehensive logging and monitoring of AI model invocations for compliance, debugging, and usage analysis purposes. The configuration supports logging to both S3 and CloudWatch with flexible data delivery options.

## Features

- **S3 Logging**: Store model invocation logs in S3 for long-term retention and analysis
- **CloudWatch Logging**: Stream logs to CloudWatch for real-time monitoring and alerting
- **Flexible Data Types**: Configure logging for text, image, video, and embedding data
- **Large Data Handling**: Special S3 configuration for handling large data payloads
- **Regional Configuration**: Manage logging configuration per AWS region
- **Compliance Support**: Enable detailed logging for audit and compliance requirements

## Important Notes

⚠️ **Regional Configuration**: Model invocation logging is configured per AWS region. To avoid overwriting settings, this resource should not be defined in multiple configurations for the same region.

## Usage

### S3 Logging Configuration

```hcl
data "aws_caller_identity" "current" {}

# Create S3 bucket for logging
resource "aws_s3_bucket" "bedrock_logs" {
  bucket        = "my-bedrock-logs-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# S3 bucket policy for Bedrock access
resource "aws_s3_bucket_policy" "bedrock_logs" {
  bucket = aws_s3_bucket.bedrock_logs.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = ["s3:*"]
        Resource = [
          "${aws_s3_bucket.bedrock_logs.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}

module "bedrock_logging_s3" {
  source = "./modules/aws-bedrock-model-invocation-logging"
  
  depends_on = [aws_s3_bucket_policy.bedrock_logs]

  logging_config = {
    embedding_data_delivery_enabled = true
    image_data_delivery_enabled     = true
    text_data_delivery_enabled      = true
    video_data_delivery_enabled     = true
    
    s3_config = {
      bucket_name = aws_s3_bucket.bedrock_logs.id
      key_prefix  = "bedrock-invocations"
    }
  }
}
```

### CloudWatch Logging Configuration

```hcl
# Create CloudWatch log group
resource "aws_cloudwatch_log_group" "bedrock_logs" {
  name              = "/aws/bedrock/model-invocations"
  retention_in_days = 30
}

# IAM role for Bedrock CloudWatch access
resource "aws_iam_role" "bedrock_cloudwatch" {
  name = "bedrock-cloudwatch-logging-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_cloudwatch" {
  name = "bedrock-cloudwatch-logging-policy"
  role = aws_iam_role.bedrock_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.bedrock_logs.arn}:*"
      }
    ]
  })
}

module "bedrock_logging_cloudwatch" {
  source = "./modules/aws-bedrock-model-invocation-logging"

  logging_config = {
    embedding_data_delivery_enabled = true
    image_data_delivery_enabled     = true
    text_data_delivery_enabled      = true
    video_data_delivery_enabled     = false
    
    cloudwatch_config = {
      log_group_name = aws_cloudwatch_log_group.bedrock_logs.name
      role_arn      = aws_iam_role.bedrock_cloudwatch.arn
    }
  }
}
```

### Hybrid Configuration (S3 + CloudWatch)

```hcl
module "bedrock_logging_hybrid" {
  source = "./modules/aws-bedrock-model-invocation-logging"

  logging_config = {
    embedding_data_delivery_enabled = true
    image_data_delivery_enabled     = true
    text_data_delivery_enabled      = true
    video_data_delivery_enabled     = true
    
    # S3 for long-term storage
    s3_config = {
      bucket_name = aws_s3_bucket.bedrock_logs.id
      key_prefix  = "bedrock-logs"
    }
    
    # CloudWatch for real-time monitoring
    cloudwatch_config = {
      log_group_name = aws_cloudwatch_log_group.bedrock_logs.name
      role_arn      = aws_iam_role.bedrock_cloudwatch.arn
      
      # S3 for large data that exceeds CloudWatch limits
      large_data_delivery_s3_config = {
        bucket_name = aws_s3_bucket.bedrock_large_data.id
        key_prefix  = "large-data"
      }
    }
  }
}
```

### Advanced Configuration with Selective Data Types

```hcl
module "bedrock_logging_selective" {
  source = "./modules/aws-bedrock-model-invocation-logging"

  logging_config = {
    # Enable only text and embedding data logging
    embedding_data_delivery_enabled = true
    image_data_delivery_enabled     = false
    text_data_delivery_enabled      = true
    video_data_delivery_enabled     = false
    
    s3_config = {
      bucket_name = aws_s3_bucket.bedrock_logs.id
      key_prefix  = "text-and-embeddings"
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_bedrock_model_invocation_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrock_model_invocation_logging_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| logging_config | The logging configuration values to set for Bedrock model invocation logging | `object` | n/a | yes |

### logging_config Object Structure

```hcl
{
  embedding_data_delivery_enabled = bool    # default: true
  image_data_delivery_enabled     = bool    # default: true
  text_data_delivery_enabled      = bool    # default: true
  video_data_delivery_enabled     = bool    # default: true
  
  s3_config = {                            # optional
    bucket_name = string                   # required
    key_prefix  = string                   # optional
  }
  
  cloudwatch_config = {                    # optional
    log_group_name = string                # required
    role_arn      = string                 # optional
    large_data_delivery_s3_config = {      # optional
      bucket_name = string                 # required
      key_prefix  = string                 # optional
    }
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | AWS Region in which logging is configured |
| logging_config | The complete logging configuration that was applied |
| s3_bucket_name | The S3 bucket name used for logging |
| s3_key_prefix | The S3 key prefix used for logging |
| cloudwatch_log_group_name | The CloudWatch log group name used for logging |
| cloudwatch_role_arn | The IAM role ARN used for CloudWatch logging |
| large_data_s3_bucket_name | The S3 bucket name used for large data delivery |
| data_delivery_settings | Summary of data delivery settings configured |

## Import

In Terraform v1.5.0 and later, use an import block to import Bedrock Invocation Logging Configuration using the AWS Region:

```hcl
import {
  to = aws_bedrock_model_invocation_logging_configuration.example
  id = "us-east-1"
}
```

Using terraform import:

```bash
terraform import aws_bedrock_model_invocation_logging_configuration.example us-east-1
```

## Data Types

The module supports configuring logging for different types of model invocation data:

- **Text Data**: Input prompts and text responses
- **Image Data**: Image inputs and generated images
- **Video Data**: Video inputs and generated videos  
- **Embedding Data**: Vector embeddings and related data

## S3 Bucket Policy Requirements

When using S3 logging, the S3 bucket must have appropriate permissions for Bedrock to write logs:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock.amazonaws.com"
      },
      "Action": ["s3:*"],
      "Resource": ["arn:aws:s3:::your-bucket/*"],
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "YOUR_ACCOUNT_ID"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:bedrock:REGION:YOUR_ACCOUNT_ID:*"
        }
      }
    }
  ]
}
```

## CloudWatch IAM Requirements

When using CloudWatch logging, Bedrock needs appropriate IAM permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:REGION:ACCOUNT:log-group:/aws/bedrock/*:*"
    }
  ]
}
```

## Use Cases

### Compliance and Auditing
- Track all AI model interactions for regulatory compliance
- Maintain detailed audit trails of model usage
- Monitor for unauthorized or inappropriate use

### Debugging and Troubleshooting
- Analyze model performance and response quality
- Debug integration issues with model invocations
- Track error patterns and failure modes

### Usage Analytics
- Monitor model usage patterns across applications
- Analyze cost optimization opportunities
- Track performance metrics and response times

### Security Monitoring
- Detect anomalous usage patterns
- Monitor for data exfiltration attempts
- Track access patterns for security analysis

## Best Practices

1. **Storage Strategy**: Use S3 for long-term retention and CloudWatch for real-time monitoring
2. **Data Selectivity**: Enable only the data types you need to optimize costs
3. **Key Prefixes**: Use descriptive S3 key prefixes for better organization
4. **IAM Permissions**: Follow principle of least privilege for IAM roles
5. **Regional Consistency**: Deploy consistently across all regions where Bedrock is used

## License

This module is licensed under the MIT License.
