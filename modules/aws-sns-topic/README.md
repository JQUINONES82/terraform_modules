# AWS SNS Topic Module

Comprehensive AWS SNS Topic module that supports all SNS features including topic creation, subscriptions, access policies, encryption, dead letter queues, and delivery status logging. Follows AWS best practices for notification management and includes comprehensive validation and security features.

## Features

- **Topic Management**: Support for standard and FIFO topics
- **Encryption**: KMS encryption support for topic security
- **Subscriptions**: Multiple subscription types (email, SMS, SQS, Lambda, HTTP/HTTPS, etc.)
- **Access Control**: Topic policies and IAM integration
- **Delivery Tracking**: Success and failure feedback for different protocols
- **Dead Letter Queues**: Support for message retry and dead letter handling
- **Content Deduplication**: FIFO topic deduplication support
- **Comprehensive Validation**: Input validation for all configuration options

## Usage

### Basic Topic

```hcl
module "sns_topic" {
  source = "../aws-sns-topic"

  name         = "my-notification-topic"
  display_name = "My Notifications"
  
  tags = {
    Environment = "production"
    Project     = "alerts"
  }
}
```

### Encrypted Topic with Subscriptions

```hcl
module "encrypted_sns_topic" {
  source = "../aws-sns-topic"

  name              = "secure-alerts"
  display_name      = "Secure Alert Notifications"
  kms_master_key_id = aws_kms_key.sns.arn
  
  subscriptions = {
    email = {
      protocol = "email"
      endpoint = "admin@company.com"
    }
    sqs = {
      protocol             = "sqs"
      endpoint             = aws_sqs_queue.alerts.arn
      raw_message_delivery = true
    }
  }

  # Create topic policy
  create_topic_policy = true
  topic_policy_principals = [
    "arn:aws:iam::123456789012:root"
  ]
  topic_policy_actions = [
    "SNS:Publish",
    "SNS:Subscribe"
  ]

  tags = {
    Environment = "production"
    Security    = "encrypted"
  }
}
```

### FIFO Topic

```hcl
module "fifo_topic" {
  source = "../aws-sns-topic"

  name                        = "orders.fifo"
  fifo_topic                 = true
  content_based_deduplication = true
  
  subscriptions = {
    order_queue = {
      protocol = "sqs"
      endpoint = aws_sqs_queue.orders.arn
    }
  }

  tags = {
    Environment = "production"
    Type        = "fifo"
  }
}
```

### Topic with Delivery Status Logging

```hcl
module "monitored_topic" {
  source = "../aws-sns-topic"

  name         = "monitored-notifications"
  display_name = "Monitored Notifications"
  
  # Lambda delivery feedback
  lambda_success_feedback_role_arn    = aws_iam_role.sns_feedback.arn
  lambda_success_feedback_sample_rate = 100
  lambda_failure_feedback_role_arn    = aws_iam_role.sns_feedback.arn
  
  # HTTP delivery feedback  
  http_success_feedback_role_arn    = aws_iam_role.sns_feedback.arn
  http_success_feedback_sample_rate = 50
  http_failure_feedback_role_arn    = aws_iam_role.sns_feedback.arn

  subscriptions = {
    webhook = {
      protocol = "https"
      endpoint = "https://api.company.com/webhooks/alerts"
    }
    processor = {
      protocol = "lambda"
      endpoint = aws_lambda_function.processor.arn
    }
  }

  tags = {
    Environment = "production"
    Monitoring  = "enabled"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| create_topic | Whether to create the SNS topic | `bool` | `true` | no |
| name | The name of the SNS topic | `string` | `null` | no |
| name_prefix | Creates a unique name beginning with the specified prefix | `string` | `null` | no |
| display_name | The display name for the topic | `string` | `null` | no |
| policy | The fully-formed AWS policy as JSON | `string` | `null` | no |
| delivery_policy | The delivery policy for the topic | `string` | `null` | no |
| kms_master_key_id | The ID of an AWS-managed customer master key (CMK) for Amazon SNS | `string` | `null` | no |
| fifo_topic | Boolean indicating whether or not to create a FIFO topic | `bool` | `false` | no |
| content_based_deduplication | Enables content-based deduplication for FIFO topics | `bool` | `null` | no |
| subscriptions | Map of subscription configurations | `map(object)` | `{}` | no |
| create_topic_policy | Whether to create a topic policy | `bool` | `false` | no |
| topic_policy | The fully-formed AWS policy as JSON for the topic | `string` | `null` | no |
| tags | A map of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the SNS topic |
| id | The ARN of the SNS topic |
| name | The name of the topic |
| display_name | The display name for the topic |
| policy | The fully-formed AWS policy as JSON |
| owner | The AWS Account ID of the SNS topic owner |
| subscription_arns | Map of subscription ARNs |
| subscription_ids | Map of subscription IDs |
| topic_policy_arn | The ARN of the topic policy |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Security Considerations

- Use KMS encryption for sensitive notifications
- Implement least-privilege topic policies
- Monitor delivery failures and implement dead letter queues
- Use FIFO topics for ordered message delivery requirements
- Enable delivery status logging for audit trails
- Validate subscription endpoints before deployment

## Examples

See the `examples/` directory for complete usage examples.
