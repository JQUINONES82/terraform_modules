/**
 * # AWS Bedrock Management Runtime Solution
 * 
 * This solution provides a secure, enterprise-grade AWS Bedrock deployment following
 * Trend Micro security best practices and using curated Terraform modules.
 * 
 * ## Features
 * - Secure VPC endpoints for Bedrock management and runtime
 * - KMS encryption for all data at rest and in transit
 * - Guardrails with PII masking and content filtering
 * - Comprehensive logging with CloudWatch and S3
 * - IAM roles with least privilege access
 * - Security groups with network segmentation
 * - Model invocation logging with encryption
 * 
 * ## Security Compliance
 * - Follows Trend Micro Bedrock security recommendations
 * - Implements cross-service confused deputy prevention
 * - Uses customer-managed KMS keys for all encryption
 * - Network isolation with VPC endpoints
 * - Least privilege IAM policies
 */

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Data sources for context
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# Local variables for resource naming and configuration
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  partition  = data.aws_partition.current.partition

  # Naming convention: <resource>-<account>-<region_suffix>-<env>
  region_suffix = replace(local.region, "-", "")

  resource_prefix = "${local.account_id}-${local.region_suffix}-${var.environment}"

  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
    Solution    = "bedrock-mgmt-runtime"
    Region      = local.region
    Account     = local.account_id
  })
}

# KMS Key for Bedrock encryption (following Trend Micro recommendations)
module "bedrock_kms_key" {
  source = "../aws-kms-key"

  description             = "KMS key for Bedrock solution encryption"
  enable_key_rotation     = true
  rotation_period_in_days = 90

  enable_alias = true
  aliases = {
    "bedrock-${local.resource_prefix}" = "Bedrock solution encryption key"
  }

  # Custom policy for Bedrock services
  policy = data.aws_iam_policy_document.bedrock_kms_policy.json

  tags = merge(local.common_tags, {
    Name    = "kms-bedrock-${local.resource_prefix}"
    Purpose = "bedrock-encryption"
  })
}

# KMS policy for Bedrock services
data "aws_iam_policy_document" "bedrock_kms_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow Bedrock Service"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudWatch Logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${local.region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

# S3 Bucket for Bedrock logs with comprehensive security
module "bedrock_logs_bucket" {
  source = "../aws-s3-bucket"

  bucket = "bedrock-logs-${local.resource_prefix}"

  # Security configurations
  versioning_enabled            = true
  block_public_acls             = true
  block_public_policy           = true
  ignore_public_acls            = true
  restrict_public_buckets       = true
  enable_server_side_encryption = true
  kms_master_key_id             = module.bedrock_kms_key.key_arn

  # Additional required parameters
  request_payer    = "BucketOwner"
  object_ownership = "BucketOwnerEnforced"

  tags = merge(local.common_tags, {
    Name    = "s3-bedrock-logs-${local.resource_prefix}"
    Purpose = "bedrock-logging"
  })
}

# CloudWatch Log Group for Bedrock invocations
resource "aws_cloudwatch_log_group" "bedrock_invocations" {
  name              = "clw-log-${local.resource_prefix}"
  retention_in_days = var.log_retention_days
  kms_key_id        = module.bedrock_kms_key.key_arn

  tags = merge(local.common_tags, {
    Name    = "clw-log-${local.resource_prefix}"
    Purpose = "bedrock-invocation-logging"
  })
}

# IAM Role for Bedrock logging with least privilege
module "bedrock_logging_role" {
  source = "../aws-iam-role"

  name        = "bedrock-logging-${local.resource_prefix}"
  description = "IAM role for Bedrock model invocation logging"

  assume_role_policy = data.aws_iam_policy_document.bedrock_logging_assume.json

  # Permissions boundary for enhanced security (Trend Micro recommendation)
  permissions_boundary = var.permissions_boundary_arn

  tags = merge(local.common_tags, {
    Name    = "role-bedrock-logging-${local.resource_prefix}"
    Purpose = "bedrock-logging"
  })
}

# Assume role policy for Bedrock service
data "aws_iam_policy_document" "bedrock_logging_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]

    # Cross-service confused deputy prevention (Trend Micro recommendation)
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:bedrock:${local.region}:${local.account_id}:*"]
    }
  }
}

# IAM policy for Bedrock logging permissions
module "bedrock_logging_policy" {
  source = "../aws-iam-policy"

  name        = "bedrock-logging-policy-${local.resource_prefix}"
  description = "Policy for Bedrock logging service"

  policy = data.aws_iam_policy_document.bedrock_logging_permissions.json

  tags = merge(local.common_tags, {
    Name    = "policy-bedrock-logging-${local.resource_prefix}"
    Purpose = "bedrock-logging"
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "bedrock_logging" {
  role       = module.bedrock_logging_role.name
  policy_arn = module.bedrock_logging_policy.arn
}

# Bedrock logging permissions
data "aws_iam_policy_document" "bedrock_logging_permissions" {
  statement {
    sid    = "CloudWatchLogsAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [
      aws_cloudwatch_log_group.bedrock_invocations.arn,
      "${aws_cloudwatch_log_group.bedrock_invocations.arn}:*"
    ]
  }

  statement {
    sid    = "S3LoggingAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [
      module.bedrock_logs_bucket.arn,
      "${module.bedrock_logs_bucket.arn}/*"
    ]
  }

  statement {
    sid    = "KMSAccess"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [module.bedrock_kms_key.key_arn]
  }
}

# Security Groups for VPC Endpoints
# Management security group - restricted to 10.20.0.0/8 on port 443
module "bedrock_management_sg" {
  source = "../aws-security-group"

  name        = "sg-bedrock-mgmt-${local.resource_prefix}"
  description = "Security group for Bedrock management VPC endpoint"
  vpc_id      = var.vpc_id

  ingress_rules = [
    {
      description = "HTTPS access from management network"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = var.management_allowed_cidrs[0]
    }
  ]

  egress_rules = [
    {
      description = "All outbound traffic"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  tags = merge(local.common_tags, {
    Name    = "sg-bedrock-mgmt-${local.resource_prefix}"
    Purpose = "bedrock-management-endpoint"
  })
}

# Runtime security group - restricted to specific runtime networks
module "bedrock_runtime_sg" {
  source = "../aws-security-group"

  name        = "sg-bedrock-runtime-${local.resource_prefix}"
  description = "Security group for Bedrock runtime VPC endpoint"
  vpc_id      = var.vpc_id

  ingress_rules = [
    {
      description = "HTTPS access from runtime networks"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = var.runtime_allowed_cidrs[0]
    }
  ]

  egress_rules = [
    {
      description = "All outbound traffic"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  tags = merge(local.common_tags, {
    Name    = "sg-bedrock-runtime-${local.resource_prefix}"
    Purpose = "bedrock-runtime-endpoint"
  })
}

# General security group for other Bedrock services - limited to VPC CIDR
module "bedrock_general_sg" {
  source = "../aws-security-group"

  name        = "sg-bedrock-general-${local.resource_prefix}"
  description = "Security group for other Bedrock VPC endpoints"
  vpc_id      = var.vpc_id

  ingress_rules = [
    {
      description = "HTTPS access from VPC"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = var.vpc_cidr
    }
  ]

  egress_rules = [
    {
      description = "All outbound traffic"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  tags = merge(local.common_tags, {
    Name    = "sg-bedrock-general-${local.resource_prefix}"
    Purpose = "bedrock-general-endpoints"
  })
}

# VPC Endpoint Policies
# Policy for Bedrock management endpoint
data "aws_iam_policy_document" "bedrock_management_endpoint_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["bedrock:*"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = ["arn:${local.partition}:iam::${local.account_id}:role/${var.bedrock_role_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [local.region]
    }
  }
}

# Policy for Bedrock runtime endpoint
data "aws_iam_policy_document" "bedrock_runtime_endpoint_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:role/${var.bedrock_role_name}"]
    }
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
      "bedrock:ApplyGuardrail"
    ]
    resources = concat(
      [for region in var.allowed_model_regions :
        "arn:${local.partition}:bedrock:${region}::foundation-model/*"
      ],
      var.foundation_models
    )

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = var.allowed_model_regions
    }
  }
}

# VPC Endpoints using the curated module
# Bedrock Management endpoint
module "bedrock_management_endpoint" {
  source = "../aws-vpc-endpoint"
  count  = var.enable_bedrock_management_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${local.region}.bedrock"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [module.bedrock_management_sg.id]
  private_dns_enabled = var.enable_private_dns

  policy = (length(var.custom_endpoint_policies) > 0 && contains(keys(var.custom_endpoint_policies), "management")) ? var.custom_endpoint_policies["management"] : data.aws_iam_policy_document.bedrock_management_endpoint_policy.json

  tags = merge(local.common_tags, {
    Name    = "vpce-bedrock-mgmt-${local.resource_prefix}"
    Purpose = "bedrock-management"
  })
}

# Bedrock Runtime endpoint
module "bedrock_runtime_endpoint" {
  source = "../aws-vpc-endpoint"
  count  = var.enable_bedrock_runtime_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${local.region}.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [module.bedrock_runtime_sg.id]
  private_dns_enabled = var.enable_private_dns

  policy = (length(var.custom_endpoint_policies) > 0 && contains(keys(var.custom_endpoint_policies), "runtime")) ? var.custom_endpoint_policies["runtime"] : data.aws_iam_policy_document.bedrock_runtime_endpoint_policy.json

  tags = merge(local.common_tags, {
    Name    = "vpce-bedrock-runtime-${local.resource_prefix}"
    Purpose = "bedrock-runtime"
  })
}

# Bedrock Agent endpoint
module "bedrock_agent_endpoint" {
  source = "../aws-vpc-endpoint"
  count  = var.enable_bedrock_agent_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${local.region}.bedrock-agent"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [module.bedrock_general_sg.id]
  private_dns_enabled = var.enable_private_dns

  tags = merge(local.common_tags, {
    Name    = "vpce-bedrock-agent-${local.resource_prefix}"
    Purpose = "bedrock-agent"
  })
}

# Bedrock Agent Runtime endpoint
module "bedrock_agent_runtime_endpoint" {
  source = "../aws-vpc-endpoint"
  count  = var.enable_bedrock_agent_runtime_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${local.region}.bedrock-agent-runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [module.bedrock_general_sg.id]
  private_dns_enabled = var.enable_private_dns

  tags = merge(local.common_tags, {
    Name    = "vpce-bedrock-agent-runtime-${local.resource_prefix}"
    Purpose = "bedrock-agent-runtime"
  })
}

# Bedrock Guardrails (following Trend Micro recommendations)
module "bedrock_guardrail" {
  source = "../aws-bedrock-guardrail"
  count  = var.enable_guardrails ? 1 : 0

  name        = var.guardrail_name != null ? var.guardrail_name : "guardrails-${local.resource_prefix}"
  description = "Enterprise content safety and PII protection guardrail"

  blocked_input_messaging   = "This content has been blocked due to policy violations."
  blocked_outputs_messaging = "The response has been blocked due to policy violations."

  # KMS encryption (Trend Micro recommendation)
  kms_key_arn = module.bedrock_kms_key.key_arn

  # Content filters with HIGH strength (Trend Micro recommendation)
  content_policy_config = {
    filters_config = [
      for filter_type, config in var.content_filters : {
        type            = upper(filter_type)
        input_strength  = config.input_strength
        output_strength = config.output_strength
      }
    ]
  }

  # Sensitive information filters (Trend Micro recommendation)
  sensitive_information_policy_config = {
    pii_entities_config = [
      {
        action = var.pii_entities_action
        type   = "ALL"
      }
    ]
  }

  # Word filters for additional protection
  word_policy_config = {
    managed_word_lists_config = [
      {
        type = "PROFANITY"
      }
    ]
  }

  tags = merge(local.common_tags, {
    Name    = "guardrail-${local.resource_prefix}"
    Purpose = "content-safety-pii-protection"
  })
}

# Model Invocation Logging Configuration
module "bedrock_model_invocation_logging" {
  source = "../aws-bedrock-model-invocation-logging"
  count  = var.enable_model_invocation_logging ? 1 : 0

  logging_config = {
    # Data delivery configuration
    text_data_delivery_enabled      = var.text_data_delivery_enabled
    image_data_delivery_enabled     = var.image_data_delivery_enabled
    embedding_data_delivery_enabled = var.embedding_data_delivery_enabled

    # CloudWatch configuration
    cloudwatch_config = var.enable_cloudwatch_logging ? {
      log_group_name = aws_cloudwatch_log_group.bedrock_invocations.name
      role_arn       = module.bedrock_logging_role.role_arn
    } : null

    # S3 configuration
    s3_config = var.enable_s3_logging ? {
      bucket_name = module.bedrock_logs_bucket.id
      key_prefix  = var.s3_log_prefix
    } : null
  }
}

# Additional security: S3 bucket policy for secure transport
resource "aws_s3_bucket_policy" "bedrock_logs_security" {
  bucket = module.bedrock_logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          module.bedrock_logs_bucket.arn,
          "${module.bedrock_logs_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid       = "DenyUnEncryptedObjectUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${module.bedrock_logs_bucket.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      }
    ]
  })
}

# SNS Topics for Alerting
# Critical alerts topic for high-priority issues
module "bedrock_critical_alerts" {
  source = "../aws-sns-topic"
  count  = var.enable_alerting ? 1 : 0

  name              = "bedrock-critical-alerts-${local.resource_prefix}"
  display_name      = "Bedrock Critical Alerts"
  kms_master_key_id = var.enable_sns_encryption ? module.bedrock_kms_key.key_arn : null

  subscriptions = var.critical_alert_subscriptions

  create_topic_policy     = true
  topic_policy_principals = var.sns_topic_principals
  topic_policy_actions = [
    "SNS:Publish",
    "SNS:Subscribe",
    "SNS:GetTopicAttributes"
  ]

  tags = merge(local.common_tags, {
    Name    = "sns-bedrock-critical-${local.resource_prefix}"
    Purpose = "bedrock-critical-alerts"
    Type    = "notification"
  })
}

# Performance alerts topic for monitoring issues
module "bedrock_performance_alerts" {
  source = "../aws-sns-topic"
  count  = var.enable_alerting ? 1 : 0

  name              = "bedrock-performance-alerts-${local.resource_prefix}"
  display_name      = "Bedrock Performance Alerts"
  kms_master_key_id = var.enable_sns_encryption ? module.bedrock_kms_key.key_arn : null

  subscriptions = var.performance_alert_subscriptions

  create_topic_policy     = true
  topic_policy_principals = var.sns_topic_principals

  tags = merge(local.common_tags, {
    Name    = "sns-bedrock-performance-${local.resource_prefix}"
    Purpose = "bedrock-performance-alerts"
    Type    = "notification"
  })
}

# Cost alerts topic for billing anomalies
module "bedrock_cost_alerts" {
  source = "../aws-sns-topic"
  count  = var.enable_cost_alerting ? 1 : 0

  name              = "bedrock-cost-alerts-${local.resource_prefix}"
  display_name      = "Bedrock Cost Alerts"
  kms_master_key_id = var.enable_sns_encryption ? module.bedrock_kms_key.key_arn : null

  subscriptions = var.cost_alert_subscriptions

  create_topic_policy     = true
  topic_policy_principals = var.sns_topic_principals

  tags = merge(local.common_tags, {
    Name    = "sns-bedrock-cost-${local.resource_prefix}"
    Purpose = "bedrock-cost-alerts"
    Type    = "notification"
  })
}

# CloudWatch Alarms for Bedrock Runtime Metrics

# Model Invocation Error Rate Alarm
module "bedrock_invocation_errors_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting ? 1 : 0

  alarm_name          = "bedrock-invocation-errors-${local.resource_prefix}"
  alarm_description   = "High error rate on Bedrock model invocations"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  datapoints_to_alarm = var.alarm_datapoints_to_alarm
  metric_name         = "InvocationClientErrors"
  namespace           = "AWS/Bedrock"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.invocation_error_threshold
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.bedrock_critical_alerts[0].arn]
  ok_actions    = var.enable_ok_actions ? [module.bedrock_critical_alerts[0].arn] : []

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-errors-${local.resource_prefix}"
    MetricType = "error-rate"
    Severity   = "critical"
  })
}

# Model Invocation Server Error Alarm
module "bedrock_server_errors_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting ? 1 : 0

  alarm_name          = "bedrock-server-errors-${local.resource_prefix}"
  alarm_description   = "High server error rate on Bedrock model invocations"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "InvocationServerErrors"
  namespace           = "AWS/Bedrock"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.server_error_threshold

  alarm_actions = [module.bedrock_critical_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-server-errors-${local.resource_prefix}"
    MetricType = "server-error"
    Severity   = "critical"
  })
}

# Model Invocation Throttle Alarm
module "bedrock_throttle_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting ? 1 : 0

  alarm_name          = "bedrock-throttles-${local.resource_prefix}"
  alarm_description   = "High throttling rate on Bedrock model invocations"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "InvocationThrottles"
  namespace           = "AWS/Bedrock"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.throttle_threshold

  alarm_actions = [module.bedrock_performance_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-throttles-${local.resource_prefix}"
    MetricType = "throttling"
    Severity   = "warning"
  })
}

# Model Invocation Latency Alarm (P99)
module "bedrock_latency_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting ? 1 : 0

  alarm_name          = "bedrock-high-latency-${local.resource_prefix}"
  alarm_description   = "High P99 latency on Bedrock model invocations"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  datapoints_to_alarm = var.alarm_datapoints_to_alarm
  metric_name         = "InvocationLatency"
  namespace           = "AWS/Bedrock"
  period              = var.alarm_period
  extended_statistic  = "p99"
  threshold           = var.latency_threshold_ms
  unit                = "Milliseconds"
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.bedrock_performance_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-latency-${local.resource_prefix}"
    MetricType = "latency"
    Severity   = "warning"
    Percentile = "p99"
  })
}

# Model Invocation Rate Anomaly Detection
module "bedrock_invocation_anomaly_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_anomaly_detection ? 1 : 0

  alarm_type         = "anomaly"
  alarm_name         = "bedrock-invocation-anomaly-${local.resource_prefix}"
  alarm_description  = "Unusual pattern in Bedrock model invocations"
  evaluation_periods = var.anomaly_evaluation_periods
  metric_name        = "Invocations"
  namespace          = "AWS/Bedrock"
  period             = var.anomaly_period
  statistic          = "Sum"
  anomaly_threshold  = var.anomaly_threshold

  alarm_actions = [module.bedrock_performance_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-anomaly-${local.resource_prefix}"
    MetricType = "anomaly-detection"
    Severity   = "info"
  })
}

# Model Invocation Logging Delivery Failure Alarms
module "bedrock_cloudwatch_delivery_failure_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_model_invocation_logging && var.enable_cloudwatch_logging ? 1 : 0

  alarm_name          = "bedrock-cloudwatch-delivery-failure-${local.resource_prefix}"
  alarm_description   = "Failures in delivering model invocation logs to CloudWatch"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ModelInvocationLogsCloudWatchDeliveryFailure"
  namespace           = "AWS/Bedrock"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.logging_failure_threshold

  alarm_actions = [module.bedrock_critical_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-cw-delivery-${local.resource_prefix}"
    MetricType = "logging-failure"
    Severity   = "critical"
  })
}

module "bedrock_s3_delivery_failure_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_model_invocation_logging && var.enable_s3_logging ? 1 : 0

  alarm_name          = "bedrock-s3-delivery-failure-${local.resource_prefix}"
  alarm_description   = "Failures in delivering model invocation logs to S3"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ModelInvocationLogsS3DeliveryFailure"
  namespace           = "AWS/Bedrock"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.logging_failure_threshold

  alarm_actions = [module.bedrock_critical_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-s3-delivery-${local.resource_prefix}"
    MetricType = "logging-failure"
    Severity   = "critical"
  })
}

# Token Usage Monitoring
module "bedrock_input_token_anomaly_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_token_monitoring ? 1 : 0

  alarm_type         = "anomaly"
  alarm_name         = "bedrock-input-token-anomaly-${local.resource_prefix}"
  alarm_description  = "Unusual pattern in input token usage"
  evaluation_periods = var.anomaly_evaluation_periods
  metric_name        = "InputTokenCount"
  namespace          = "AWS/Bedrock"
  period             = var.anomaly_period
  statistic          = "Sum"
  anomaly_threshold  = var.token_anomaly_threshold

  alarm_actions = [module.bedrock_cost_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-input-tokens-${local.resource_prefix}"
    MetricType = "token-usage"
    Severity   = "info"
  })
}

module "bedrock_output_token_anomaly_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_token_monitoring ? 1 : 0

  alarm_type         = "anomaly"
  alarm_name         = "bedrock-output-token-anomaly-${local.resource_prefix}"
  alarm_description  = "Unusual pattern in output token usage"
  evaluation_periods = var.anomaly_evaluation_periods
  metric_name        = "OutputTokenCount"
  namespace          = "AWS/Bedrock"
  period             = var.anomaly_period
  statistic          = "Sum"
  anomaly_threshold  = var.token_anomaly_threshold

  alarm_actions = [module.bedrock_cost_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-output-tokens-${local.resource_prefix}"
    MetricType = "token-usage"
    Severity   = "info"
  })
}

# Composite Alarm for Overall Bedrock Health
module "bedrock_health_composite_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_composite_alarms ? 1 : 0

  alarm_type        = "composite"
  alarm_name        = "bedrock-overall-health-${local.resource_prefix}"
  alarm_description = "Overall health status of Bedrock service based on multiple metrics"

  alarm_rule = join(" OR ", compact([
    var.enable_alerting ? "ALARM(${module.bedrock_invocation_errors_alarm[0].alarm_name})" : "",
    var.enable_alerting ? "ALARM(${module.bedrock_server_errors_alarm[0].alarm_name})" : "",
    var.enable_model_invocation_logging && var.enable_cloudwatch_logging ? "ALARM(${module.bedrock_cloudwatch_delivery_failure_alarm[0].alarm_name})" : "",
    var.enable_model_invocation_logging && var.enable_s3_logging ? "ALARM(${module.bedrock_s3_delivery_failure_alarm[0].alarm_name})" : ""
  ]))

  alarm_actions = [module.bedrock_critical_alerts[0].arn]

  # Suppress actions during maintenance windows if configured
  actions_suppressor = var.maintenance_window_alarm_arn != null ? {
    alarm            = var.maintenance_window_alarm_arn
    extension_period = var.maintenance_suppression_extension_period
    wait_period      = var.maintenance_suppression_wait_period
  } : null

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-health-${local.resource_prefix}"
    MetricType = "composite"
    Severity   = "critical"
    Purpose    = "overall-health"
  })
}

# ===================================================================
# ADDITIONAL BEDROCK AGENTS AND KNOWLEDGE BASE METRICS MONITORING
# ===================================================================

# Bedrock Agents Error Monitoring
module "bedrock_agents_client_errors_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_agents_monitoring ? 1 : 0

  alarm_name          = "bedrock-agents-client-errors-${local.resource_prefix}"
  alarm_description   = "High client error rate on Bedrock Agents"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "InvocationClientErrors"
  namespace           = "AWS/BedrockAgent"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.agents_error_threshold
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.bedrock_critical_alerts[0].arn]
  ok_actions    = var.enable_ok_actions ? [module.bedrock_critical_alerts[0].arn] : []

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-agents-errors-${local.resource_prefix}"
    MetricType = "error-rate"
    Service    = "bedrock-agents"
    Severity   = "critical"
  })
}

module "bedrock_agents_server_errors_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_agents_monitoring ? 1 : 0

  alarm_name          = "bedrock-agents-server-errors-${local.resource_prefix}"
  alarm_description   = "High server error rate on Bedrock Agents"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "InvocationServerErrors"
  namespace           = "AWS/BedrockAgent"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.agents_error_threshold

  alarm_actions = [module.bedrock_critical_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-agents-server-errors-${local.resource_prefix}"
    MetricType = "server-error"
    Service    = "bedrock-agents"
    Severity   = "critical"
  })
}

# Bedrock Agents Latency Monitoring
module "bedrock_agents_latency_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_agents_monitoring ? 1 : 0

  alarm_name          = "bedrock-agents-high-latency-${local.resource_prefix}"
  alarm_description   = "High P99 latency on Bedrock Agents invocations"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  datapoints_to_alarm = var.alarm_datapoints_to_alarm
  metric_name         = "InvocationLatency"
  namespace           = "AWS/BedrockAgent"
  period              = var.alarm_period
  extended_statistic  = "p99"
  threshold           = var.agents_latency_threshold_ms
  unit                = "Milliseconds"
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.bedrock_performance_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-agents-latency-${local.resource_prefix}"
    MetricType = "latency"
    Service    = "bedrock-agents"
    Severity   = "warning"
    Percentile = "p99"
  })
}

# Bedrock Agents Throttling Monitoring
module "bedrock_agents_throttle_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_agents_monitoring ? 1 : 0

  alarm_name          = "bedrock-agents-throttles-${local.resource_prefix}"
  alarm_description   = "High throttling rate on Bedrock Agents"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "InvocationThrottles"
  namespace           = "AWS/BedrockAgent"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.agents_throttle_threshold

  alarm_actions = [module.bedrock_performance_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-agents-throttles-${local.resource_prefix}"
    MetricType = "throttling"
    Service    = "bedrock-agents"
    Severity   = "warning"
  })
}

# Bedrock Knowledge Base Error Monitoring
module "bedrock_kb_client_errors_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_knowledge_base_monitoring ? 1 : 0

  alarm_name          = "bedrock-kb-client-errors-${local.resource_prefix}"
  alarm_description   = "High client error rate on Bedrock Knowledge Base queries"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "RetrieveClientErrors"
  namespace           = "AWS/BedrockAgent"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.kb_error_threshold
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.bedrock_critical_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-kb-errors-${local.resource_prefix}"
    MetricType = "error-rate"
    Service    = "bedrock-knowledge-base"
    Severity   = "critical"
  })
}

module "bedrock_kb_server_errors_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_knowledge_base_monitoring ? 1 : 0

  alarm_name          = "bedrock-kb-server-errors-${local.resource_prefix}"
  alarm_description   = "High server error rate on Bedrock Knowledge Base queries"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "RetrieveServerErrors"
  namespace           = "AWS/BedrockAgent"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.kb_error_threshold

  alarm_actions = [module.bedrock_critical_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-kb-server-errors-${local.resource_prefix}"
    MetricType = "server-error"
    Service    = "bedrock-knowledge-base"
    Severity   = "critical"
  })
}

# Bedrock Knowledge Base Latency Monitoring
module "bedrock_kb_latency_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_knowledge_base_monitoring ? 1 : 0

  alarm_name          = "bedrock-kb-high-latency-${local.resource_prefix}"
  alarm_description   = "High P99 latency on Bedrock Knowledge Base retrieval"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  datapoints_to_alarm = var.alarm_datapoints_to_alarm
  metric_name         = "RetrieveLatency"
  namespace           = "AWS/BedrockAgent"
  period              = var.alarm_period
  extended_statistic  = "p99"
  threshold           = var.kb_latency_threshold_ms
  unit                = "Milliseconds"
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.bedrock_performance_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-kb-latency-${local.resource_prefix}"
    MetricType = "latency"
    Service    = "bedrock-knowledge-base"
    Severity   = "warning"
    Percentile = "p99"
  })
}

# Bedrock Knowledge Base Throttling Monitoring
module "bedrock_kb_throttle_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_knowledge_base_monitoring ? 1 : 0

  alarm_name          = "bedrock-kb-throttles-${local.resource_prefix}"
  alarm_description   = "High throttling rate on Bedrock Knowledge Base queries"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "RetrieveThrottles"
  namespace           = "AWS/BedrockAgent"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.kb_throttle_threshold

  alarm_actions = [module.bedrock_performance_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-kb-throttles-${local.resource_prefix}"
    MetricType = "throttling"
    Service    = "bedrock-knowledge-base"
    Severity   = "warning"
  })
}

# Bedrock Guardrails Metrics Monitoring
module "bedrock_guardrails_blocked_input_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_guardrails && var.enable_guardrails_monitoring ? 1 : 0

  alarm_name          = "bedrock-guardrails-blocked-input-${local.resource_prefix}"
  alarm_description   = "High rate of blocked inputs by Bedrock Guardrails"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "GuardrailsBlockedInputs"
  namespace           = "AWS/Bedrock"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.guardrails_blocked_threshold
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.bedrock_performance_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-guardrails-blocked-${local.resource_prefix}"
    MetricType = "security"
    Service    = "bedrock-guardrails"
    Severity   = "info"
  })
}

module "bedrock_guardrails_blocked_output_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_guardrails && var.enable_guardrails_monitoring ? 1 : 0

  alarm_name          = "bedrock-guardrails-blocked-output-${local.resource_prefix}"
  alarm_description   = "High rate of blocked outputs by Bedrock Guardrails"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "GuardrailsBlockedOutputs"
  namespace           = "AWS/Bedrock"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.guardrails_blocked_threshold
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.bedrock_performance_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-guardrails-blocked-output-${local.resource_prefix}"
    MetricType = "security"
    Service    = "bedrock-guardrails"
    Severity   = "info"
  })
}

# API Call Rate Monitoring
module "bedrock_api_call_anomaly_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_anomaly_detection && var.enable_api_call_monitoring ? 1 : 0

  alarm_type         = "anomaly"
  alarm_name         = "bedrock-api-calls-anomaly-${local.resource_prefix}"
  alarm_description  = "Unusual pattern in Bedrock API calls"
  evaluation_periods = var.anomaly_evaluation_periods
  metric_name        = "APICallCount"
  namespace          = "AWS/Bedrock"
  period             = var.anomaly_period
  statistic          = "Sum"
  anomaly_threshold  = var.anomaly_threshold

  alarm_actions = [module.bedrock_performance_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-api-anomaly-${local.resource_prefix}"
    MetricType = "api-usage"
    Severity   = "info"
  })
}

# Model Training Job Monitoring (if using Custom Models)
module "bedrock_training_job_failures_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_training_monitoring ? 1 : 0

  alarm_name          = "bedrock-training-job-failures-${local.resource_prefix}"
  alarm_description   = "Failed training jobs in Bedrock"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.training_alarm_evaluation_periods
  metric_name         = "TrainingJobFailures"
  namespace           = "AWS/Bedrock"
  period              = var.training_alarm_period
  statistic           = "Sum"
  threshold           = var.training_job_failure_threshold
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.bedrock_critical_alerts[0].arn]

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-training-failures-${local.resource_prefix}"
    MetricType = "training"
    Service    = "bedrock-custom-models"
    Severity   = "critical"
  })
}

# Enhanced Composite Alarm with Additional Services
module "bedrock_comprehensive_health_composite_alarm" {
  source = "../aws-cloudwatch-alarm"
  count  = var.enable_alerting && var.enable_comprehensive_health_monitoring ? 1 : 0

  alarm_type        = "composite"
  alarm_name        = "bedrock-comprehensive-health-${local.resource_prefix}"
  alarm_description = "Comprehensive health status including Agents, Knowledge Bases, and Guardrails"

  alarm_rule = join(" OR ", compact([
    # Runtime metrics
    var.enable_alerting ? "ALARM(${module.bedrock_invocation_errors_alarm[0].alarm_name})" : "",
    var.enable_alerting ? "ALARM(${module.bedrock_server_errors_alarm[0].alarm_name})" : "",
    # Agents metrics
    var.enable_alerting && var.enable_agents_monitoring ? "ALARM(${module.bedrock_agents_client_errors_alarm[0].alarm_name})" : "",
    var.enable_alerting && var.enable_agents_monitoring ? "ALARM(${module.bedrock_agents_server_errors_alarm[0].alarm_name})" : "",
    # Knowledge Base metrics
    var.enable_alerting && var.enable_knowledge_base_monitoring ? "ALARM(${module.bedrock_kb_client_errors_alarm[0].alarm_name})" : "",
    var.enable_alerting && var.enable_knowledge_base_monitoring ? "ALARM(${module.bedrock_kb_server_errors_alarm[0].alarm_name})" : "",
    # Logging delivery failures
    var.enable_model_invocation_logging && var.enable_cloudwatch_logging ? "ALARM(${module.bedrock_cloudwatch_delivery_failure_alarm[0].alarm_name})" : "",
    var.enable_model_invocation_logging && var.enable_s3_logging ? "ALARM(${module.bedrock_s3_delivery_failure_alarm[0].alarm_name})" : "",
    # Training failures
    var.enable_alerting && var.enable_training_monitoring ? "ALARM(${module.bedrock_training_job_failures_alarm[0].alarm_name})" : ""
  ]))

  alarm_actions = [module.bedrock_critical_alerts[0].arn]

  # Suppress actions during maintenance windows if configured
  actions_suppressor = var.maintenance_window_alarm_arn != null ? {
    alarm            = var.maintenance_window_alarm_arn
    extension_period = var.maintenance_suppression_extension_period
    wait_period      = var.maintenance_suppression_wait_period
  } : null

  tags = merge(local.common_tags, {
    Name       = "alarm-bedrock-comprehensive-health-${local.resource_prefix}"
    MetricType = "composite"
    Severity   = "critical"
    Purpose    = "comprehensive-health"
    Coverage   = "all-services"
  })
}

# ===================================================================
# COST MANAGEMENT AND BUDGETING
# ===================================================================

# Bedrock-Specific Budget for Cost Management
module "bedrock_cost_budget" {
  source = "../aws-budget"
  count  = var.enable_budget_monitoring ? 1 : 0

  budget_name  = "bedrock-ai-services-budget-${var.environment}"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.bedrock_monthly_budget_limit
  limit_unit   = "USD"

  # Filter for Bedrock and related AI services
  cost_filters = {
    service = concat(
      ["Amazon Bedrock"],
      var.include_related_ai_services ? [
        "Amazon SageMaker",
        "Amazon Comprehend",
        "Amazon Textract",
        "Amazon Rekognition",
        "Amazon Translate",
        "Amazon Transcribe",
        "Amazon Polly"
      ] : []
    )
    
    # Filter by tags if provided
    tag = var.budget_cost_filter_tags
  }

  notifications = [
    # Early warning at 50%
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = var.budget_warning_threshold
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = var.budget_warning_emails
      subscriber_sns_topic_arns  = var.enable_cost_alerting && length(module.bedrock_cost_alerts) > 0 ? [module.bedrock_cost_alerts[0].arn] : []
    },
    # Critical alert at 80%
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = var.budget_critical_threshold
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = var.budget_critical_emails
      subscriber_sns_topic_arns  = var.enable_cost_alerting && length(module.bedrock_cost_alerts) > 0 ? [module.bedrock_cost_alerts[0].arn] : []
    },
    # Forecast alert at 100%
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = var.budget_forecast_threshold
      threshold_type            = "PERCENTAGE"
      notification_type         = "FORECASTED"
      subscriber_email_addresses = var.budget_forecast_emails
      subscriber_sns_topic_arns  = var.enable_cost_alerting && length(module.bedrock_cost_alerts) > 0 ? [module.bedrock_cost_alerts[0].arn] : []
    }
  ]

  # Enable anomaly detection for cost monitoring
  enable_anomaly_detection = var.enable_budget_anomaly_detection
  anomaly_threshold_value  = var.budget_anomaly_threshold
  anomaly_subscription_frequency = var.budget_anomaly_frequency
  anomaly_subscriber_email_addresses = var.budget_anomaly_emails
  anomaly_subscriber_sns_topic_arns   = var.enable_cost_alerting && length(module.bedrock_cost_alerts) > 0 ? [module.bedrock_cost_alerts[0].arn] : []

  # Auto-adjustment configuration
  auto_adjust_type = var.budget_auto_adjust_type
  historical_options_budget_adjustment_period = var.budget_historical_adjustment_period

  tags = merge(local.common_tags, {
    Name        = "budget-bedrock-${local.resource_prefix}"
    Purpose     = "bedrock-cost-management"
    Service     = "bedrock"
    BudgetType  = "ai-services"
  })
}

# Token Usage Budget (separate budget for token consumption tracking)
module "bedrock_token_budget" {
  source = "../aws-budget"
  count  = var.enable_token_budget_monitoring ? 1 : 0

  budget_name  = "bedrock-token-usage-budget-${var.environment}"
  budget_type  = "USAGE"
  time_unit    = "MONTHLY"
  limit_amount = var.token_monthly_budget_limit
  limit_unit   = "Tokens"

  # Filter specifically for Bedrock token usage
  cost_filters = {
    service = ["Amazon Bedrock"]
    usage_type = [
      "InputTokens",
      "OutputTokens", 
      "TokenUsage"
    ]
  }

  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = var.token_budget_threshold
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = var.token_budget_emails
      subscriber_sns_topic_arns  = var.enable_cost_alerting && length(module.bedrock_cost_alerts) > 0 ? [module.bedrock_cost_alerts[0].arn] : []
    }
  ]

  # Enable token usage anomaly detection
  enable_anomaly_detection = var.enable_token_anomaly_detection
  anomaly_threshold_value  = var.token_anomaly_threshold_value
  anomaly_subscriber_email_addresses = var.token_budget_emails

  tags = merge(local.common_tags, {
    Name        = "budget-bedrock-tokens-${local.resource_prefix}"
    Purpose     = "bedrock-token-tracking"
    Service     = "bedrock"
    BudgetType  = "usage-tracking"
  })
}
