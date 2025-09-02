/**
 * Variables for AWS Bedrock Management Runtime Solution
 */

# Core configuration variables
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where Bedrock endpoints will be deployed"
  type        = string
  default     = "vpc-0123456789abcdef"
}

variable "subnet_ids" {
  description = "List of subnet IDs for VPC endpoints"
  type        = list(string)
  default     = ["snet-0123456789a", "snet-0123456789b"]
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

# Logging configuration
variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 90

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch Logs retention period."
  }
}

variable "s3_log_prefix" {
  description = "S3 prefix for Bedrock invocation logs"
  type        = string
  default     = "invocations/"
}

# Security configuration
variable "permissions_boundary_arn" {
  description = "ARN of the permissions boundary for IAM roles (Trend Micro recommendation)"
  type        = string
  default     = null
}

# Network configuration
variable "management_allowed_cidrs" {
  description = "CIDR blocks allowed to access Bedrock management endpoint"
  type        = list(string)
  default     = ["10.20.0.0/8"]

  validation {
    condition = alltrue([
      for cidr in var.management_allowed_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid."
  }
}

variable "runtime_allowed_cidrs" {
  description = "CIDR blocks allowed to access Bedrock runtime endpoint"
  type        = list(string)
  default     = ["10.30.0.0/16", "10.40.0.0/16"]

  validation {
    condition = alltrue([
      for cidr in var.runtime_allowed_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid."
  }
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC for general endpoint access"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

# Bedrock configuration
variable "bedrock_role_name" {
  description = "Name of the IAM role allowed to use Bedrock runtime"
  type        = string
  default     = "JQ-12345678-Bedrock"
}

variable "allowed_model_regions" {
  description = "List of AWS regions where foundation models can be accessed"
  type        = list(string)
  default     = ["us-east-1", "us-east-2", "us-west-2"]

  validation {
    condition = alltrue([
      for region in var.allowed_model_regions : can(regex("^[a-z]{2}-[a-z]+-[0-9]$", region))
    ])
    error_message = "All regions must be valid AWS region names."
  }
}

variable "foundation_models" {
  description = "List of foundation model ARNs allowed for invocation"
  type        = list(string)
  default     = []
}

# Guardrail configuration
variable "enable_guardrails" {
  description = "Whether to enable Bedrock guardrails"
  type        = bool
  default     = true
}

variable "guardrail_name" {
  description = "Name for the Bedrock guardrail"
  type        = string
  default     = null
}

variable "pii_entities_action" {
  description = "Action to take for PII entities (BLOCK, ANONYMIZE)"
  type        = string
  default     = "ANONYMIZE"

  validation {
    condition     = contains(["BLOCK", "ANONYMIZE"], var.pii_entities_action)
    error_message = "PII entities action must be either BLOCK or ANONYMIZE."
  }
}

variable "content_filters" {
  description = "Content filter configurations for guardrails"
  type = map(object({
    input_strength  = string
    output_strength = string
  }))
  default = {
    sexual = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    violence = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    hate = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    insults = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    misconduct = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    prompt_attack = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
  }
}

# VPC Endpoint configuration
variable "enable_bedrock_management_endpoint" {
  description = "Whether to create Bedrock management VPC endpoint"
  type        = bool
  default     = true
}

variable "enable_bedrock_runtime_endpoint" {
  description = "Whether to create Bedrock runtime VPC endpoint"
  type        = bool
  default     = true
}

variable "enable_bedrock_agent_endpoint" {
  description = "Whether to create Bedrock agent VPC endpoint"
  type        = bool
  default     = true
}

variable "enable_bedrock_agent_runtime_endpoint" {
  description = "Whether to create Bedrock agent runtime VPC endpoint"
  type        = bool
  default     = true
}

# Model invocation logging
variable "enable_model_invocation_logging" {
  description = "Whether to enable model invocation logging"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logging" {
  description = "Whether to enable CloudWatch logging for model invocations"
  type        = bool
  default     = true
}

variable "enable_s3_logging" {
  description = "Whether to enable S3 logging for model invocations"
  type        = bool
  default     = true
}

variable "text_data_delivery_enabled" {
  description = "Whether to enable text data delivery in logging"
  type        = bool
  default     = true
}

variable "image_data_delivery_enabled" {
  description = "Whether to enable image data delivery in logging"
  type        = bool
  default     = true
}

variable "embedding_data_delivery_enabled" {
  description = "Whether to enable embedding data delivery in logging"
  type        = bool
  default     = true
}

# Advanced configuration
variable "enable_private_dns" {
  description = "Whether to enable private DNS for VPC endpoints"
  type        = bool
  default     = true
}

variable "route_table_ids" {
  description = "List of route table IDs for VPC endpoints (if using Gateway endpoints)"
  type        = list(string)
  default     = []
}

variable "custom_endpoint_policies" {
  description = "Custom endpoint policies for VPC endpoints"
  type        = map(string)
  default     = {}
}

# Alerting and Monitoring configuration
variable "enable_alerting" {
  description = "Whether to enable CloudWatch alarms and SNS notifications"
  type        = bool
  default     = true
}

variable "enable_anomaly_detection" {
  description = "Whether to enable anomaly detection alarms"
  type        = bool
  default     = true
}

variable "enable_cost_alerting" {
  description = "Whether to enable cost-related alerting"
  type        = bool
  default     = true
}

variable "enable_token_monitoring" {
  description = "Whether to enable token usage monitoring and anomaly detection"
  type        = bool
  default     = true
}

variable "enable_composite_alarms" {
  description = "Whether to create composite alarms for overall health monitoring"
  type        = bool
  default     = true
}

variable "enable_sns_encryption" {
  description = "Whether to encrypt SNS topics with KMS"
  type        = bool
  default     = true
}

variable "enable_ok_actions" {
  description = "Whether to send notifications when alarms return to OK state"
  type        = bool
  default     = false
}

# SNS Subscription Configuration
variable "critical_alert_subscriptions" {
  description = "Map of critical alert subscription configurations"
  type = map(object({
    protocol                        = string
    endpoint                        = string
    endpoint_auto_confirms          = optional(bool)
    confirmation_timeout_in_minutes = optional(number)
    raw_message_delivery            = optional(bool)
    filter_policy                   = optional(string)
    filter_policy_scope             = optional(string)
    delivery_policy                 = optional(string)
    redrive_policy                  = optional(string)
    replay_policy                   = optional(string)
    subscription_role_arn           = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for sub in values(var.critical_alert_subscriptions) : contains([
        "sqs", "sms", "email", "email-json", "http", "https",
        "application", "lambda", "firehose"
      ], sub.protocol)
    ])
    error_message = "Protocol must be one of: sqs, sms, email, email-json, http, https, application, lambda, firehose."
  }
}

variable "performance_alert_subscriptions" {
  description = "Map of performance alert subscription configurations"
  type = map(object({
    protocol                        = string
    endpoint                        = string
    endpoint_auto_confirms          = optional(bool)
    confirmation_timeout_in_minutes = optional(number)
    raw_message_delivery            = optional(bool)
    filter_policy                   = optional(string)
    filter_policy_scope             = optional(string)
    delivery_policy                 = optional(string)
    redrive_policy                  = optional(string)
    replay_policy                   = optional(string)
    subscription_role_arn           = optional(string)
  }))
  default = {}
}

variable "cost_alert_subscriptions" {
  description = "Map of cost alert subscription configurations"
  type = map(object({
    protocol                        = string
    endpoint                        = string
    endpoint_auto_confirms          = optional(bool)
    confirmation_timeout_in_minutes = optional(number)
    raw_message_delivery            = optional(bool)
    filter_policy                   = optional(string)
    filter_policy_scope             = optional(string)
    delivery_policy                 = optional(string)
    redrive_policy                  = optional(string)
    replay_policy                   = optional(string)
    subscription_role_arn           = optional(string)
  }))
  default = {}
}

variable "sns_topic_principals" {
  description = "List of AWS principals allowed to access SNS topics"
  type        = list(string)
  default     = ["*"]
}

# CloudWatch Alarm Configuration
variable "alarm_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold"
  type        = number
  default     = 2

  validation {
    condition     = var.alarm_evaluation_periods >= 1 && var.alarm_evaluation_periods <= 10
    error_message = "Evaluation periods must be between 1 and 10."
  }
}

variable "alarm_datapoints_to_alarm" {
  description = "The number of datapoints that must be breaching to trigger the alarm"
  type        = number
  default     = 2

  validation {
    condition     = var.alarm_datapoints_to_alarm >= 1
    error_message = "Datapoints to alarm must be at least 1."
  }
}

variable "alarm_period" {
  description = "The period in seconds over which the specified statistic is applied"
  type        = number
  default     = 300

  validation {
    condition     = var.alarm_period >= 60 && (var.alarm_period % 60 == 0)
    error_message = "Period must be at least 60 seconds and be a multiple of 60."
  }
}

# Threshold Configuration
variable "invocation_error_threshold" {
  description = "Threshold for model invocation client errors alarm"
  type        = number
  default     = 10

  validation {
    condition     = var.invocation_error_threshold >= 0
    error_message = "Invocation error threshold must be non-negative."
  }
}

variable "server_error_threshold" {
  description = "Threshold for model invocation server errors alarm"
  type        = number
  default     = 5

  validation {
    condition     = var.server_error_threshold >= 0
    error_message = "Server error threshold must be non-negative."
  }
}

variable "throttle_threshold" {
  description = "Threshold for model invocation throttles alarm"
  type        = number
  default     = 20

  validation {
    condition     = var.throttle_threshold >= 0
    error_message = "Throttle threshold must be non-negative."
  }
}

variable "latency_threshold_ms" {
  description = "Threshold for model invocation latency alarm in milliseconds"
  type        = number
  default     = 10000

  validation {
    condition     = var.latency_threshold_ms > 0
    error_message = "Latency threshold must be greater than 0."
  }
}

variable "logging_failure_threshold" {
  description = "Threshold for logging delivery failure alarms"
  type        = number
  default     = 1

  validation {
    condition     = var.logging_failure_threshold >= 0
    error_message = "Logging failure threshold must be non-negative."
  }
}

# Anomaly Detection Configuration
variable "anomaly_evaluation_periods" {
  description = "The number of periods for anomaly detection evaluation"
  type        = number
  default     = 2

  validation {
    condition     = var.anomaly_evaluation_periods >= 1 && var.anomaly_evaluation_periods <= 10
    error_message = "Anomaly evaluation periods must be between 1 and 10."
  }
}

variable "anomaly_period" {
  description = "The period in seconds for anomaly detection"
  type        = number
  default     = 300

  validation {
    condition     = var.anomaly_period >= 60 && (var.anomaly_period % 60 == 0)
    error_message = "Anomaly period must be at least 60 seconds and be a multiple of 60."
  }
}

variable "anomaly_threshold" {
  description = "The value used to compare with the anomaly detection band"
  type        = number
  default     = 2

  validation {
    condition     = var.anomaly_threshold > 0
    error_message = "Anomaly threshold must be greater than 0."
  }
}

variable "token_anomaly_threshold" {
  description = "The anomaly threshold for token usage monitoring"
  type        = number
  default     = 2

  validation {
    condition     = var.token_anomaly_threshold > 0
    error_message = "Token anomaly threshold must be greater than 0."
  }
}

# Maintenance Window Configuration
variable "maintenance_window_alarm_arn" {
  description = "ARN of an alarm that indicates maintenance window (for action suppression)"
  type        = string
  default     = null
}

variable "maintenance_suppression_extension_period" {
  description = "Extension period in seconds for action suppression during maintenance"
  type        = number
  default     = 300

  validation {
    condition     = var.maintenance_suppression_extension_period >= 0
    error_message = "Extension period must be non-negative."
  }
}

variable "maintenance_suppression_wait_period" {
  description = "Wait period in seconds for action suppression during maintenance"
  type        = number
  default     = 300

  validation {
    condition     = var.maintenance_suppression_wait_period >= 0
    error_message = "Wait period must be non-negative."
  }
}

# Additional Threshold Configuration for Extended Monitoring
variable "guardrails_blocked_threshold" {
  description = "Threshold for guardrails blocked inputs/outputs alarm"
  type        = number
  default     = 50

  validation {
    condition     = var.guardrails_blocked_threshold >= 0
    error_message = "Guardrails blocked threshold must be non-negative."
  }
}

variable "training_job_failure_threshold" {
  description = "Threshold for training job failures alarm"
  type        = number
  default     = 0

  validation {
    condition     = var.training_job_failure_threshold >= 0
    error_message = "Training job failure threshold must be non-negative."
  }
}

variable "enable_agents_monitoring" {
  description = "Whether to enable monitoring for Bedrock Agents"
  type        = bool
  default     = true
}

variable "enable_knowledge_base_monitoring" {
  description = "Whether to enable monitoring for Bedrock Knowledge Bases"
  type        = bool
  default     = true
}

variable "enable_guardrails_monitoring" {
  description = "Whether to enable monitoring for Bedrock Guardrails"
  type        = bool
  default     = true
}

variable "enable_training_monitoring" {
  description = "Whether to enable monitoring for Bedrock model training jobs"
  type        = bool
  default     = true
}

variable "enable_api_call_monitoring" {
  description = "Whether to enable API call rate monitoring and anomaly detection"
  type        = bool
  default     = true
}

variable "enable_comprehensive_health_monitoring" {
  description = "Whether to enable comprehensive health monitoring including all Bedrock services"
  type        = bool
  default     = true
}

# Advanced Alarm Configuration
variable "agents_latency_threshold_ms" {
  description = "Threshold for Bedrock Agents latency alarm in milliseconds"
  type        = number
  default     = 15000

  validation {
    condition     = var.agents_latency_threshold_ms > 0
    error_message = "Agents latency threshold must be greater than 0."
  }
}

variable "kb_latency_threshold_ms" {
  description = "Threshold for Knowledge Base retrieval latency alarm in milliseconds"
  type        = number
  default     = 5000

  validation {
    condition     = var.kb_latency_threshold_ms > 0
    error_message = "Knowledge Base latency threshold must be greater than 0."
  }
}

variable "agents_throttle_threshold" {
  description = "Threshold for Bedrock Agents throttling alarm"
  type        = number
  default     = 10

  validation {
    condition     = var.agents_throttle_threshold >= 0
    error_message = "Agents throttle threshold must be non-negative."
  }
}

variable "kb_throttle_threshold" {
  description = "Threshold for Knowledge Base throttling alarm"
  type        = number
  default     = 10

  validation {
    condition     = var.kb_throttle_threshold >= 0
    error_message = "Knowledge Base throttle threshold must be non-negative."
  }
}

variable "agents_error_threshold" {
  description = "Threshold for Bedrock Agents error alarms"
  type        = number
  default     = 5

  validation {
    condition     = var.agents_error_threshold >= 0
    error_message = "Agents error threshold must be non-negative."
  }
}

variable "kb_error_threshold" {
  description = "Threshold for Knowledge Base error alarms"
  type        = number
  default     = 5

  validation {
    condition     = var.kb_error_threshold >= 0
    error_message = "Knowledge Base error threshold must be non-negative."
  }
}

# Metric-specific Evaluation Periods
variable "training_alarm_evaluation_periods" {
  description = "Evaluation periods for training job failure alarms"
  type        = number
  default     = 1

  validation {
    condition     = var.training_alarm_evaluation_periods >= 1 && var.training_alarm_evaluation_periods <= 5
    error_message = "Training alarm evaluation periods must be between 1 and 5."
  }
}

variable "training_alarm_period" {
  description = "Period for training job monitoring in seconds"
  type        = number
  default     = 3600 # 1 hour

  validation {
    condition     = var.training_alarm_period >= 300 && (var.training_alarm_period % 60 == 0)
    error_message = "Training alarm period must be at least 300 seconds and be a multiple of 60."
  }
}

# ===================================================================
# BUDGET MONITORING AND COST ALERTING
# ===================================================================

# Budget Control
variable "enable_budget_monitoring" {
  description = "Enable AWS Budget monitoring for Bedrock services"
  type        = bool
  default     = true
}

variable "enable_token_budget_monitoring" {
  description = "Enable separate budget monitoring for token usage"
  type        = bool
  default     = true
}

# Budget Configuration
variable "bedrock_monthly_budget_limit" {
  description = "Monthly budget limit for Bedrock services in USD"
  type        = string
  default     = "1000"
  
  validation {
    condition     = can(tonumber(var.bedrock_monthly_budget_limit)) && tonumber(var.bedrock_monthly_budget_limit) > 0
    error_message = "Budget limit must be a positive number."
  }
}

variable "token_monthly_budget_limit" {
  description = "Monthly budget limit for token usage"
  type        = string
  default     = "1000000"
}

# Budget Alert Email Configuration
variable "budget_notification_email" {
  description = "Primary email address for budget notifications"
  type        = string
  default     = "jq@aol.com"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.budget_notification_email))
    error_message = "Budget notification email must be a valid email address."
  }
}

variable "budget_notification_emails" {
  description = "List of email addresses for budget notifications"
  type        = list(string)
  default     = ["jq@aol.com"]
  
  validation {
    condition = alltrue([
      for email in var.budget_notification_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All budget notification emails must be valid email addresses."
  }
}

# Budget Threshold Configuration
variable "budget_warning_threshold" {
  description = "Warning threshold percentage for budget alerts (0-100)"
  type        = number
  default     = 50
  
  validation {
    condition     = var.budget_warning_threshold >= 0 && var.budget_warning_threshold <= 100
    error_message = "Budget warning threshold must be between 0 and 100."
  }
}

variable "budget_critical_threshold" {
  description = "Critical threshold percentage for budget alerts (0-100)"
  type        = number
  default     = 80
  
  validation {
    condition     = var.budget_critical_threshold >= 0 && var.budget_critical_threshold <= 100
    error_message = "Budget critical threshold must be between 0 and 100."
  }
}

variable "budget_forecast_threshold" {
  description = "Forecasted threshold percentage for budget alerts (0-200)"
  type        = number
  default     = 100
  
  validation {
    condition     = var.budget_forecast_threshold >= 0 && var.budget_forecast_threshold <= 200
    error_message = "Budget forecast threshold must be between 0 and 200."
  }
}

# Budget Alert Routing
variable "budget_warning_emails" {
  description = "Email addresses for budget warning alerts"
  type        = list(string)
  default     = ["jq@aol.com"]
  
  validation {
    condition = alltrue([
      for email in var.budget_warning_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All budget warning emails must be valid email addresses."
  }
}

variable "budget_critical_emails" {
  description = "Email addresses for budget critical alerts"
  type        = list(string)
  default     = ["jq@aol.com"]
  
  validation {
    condition = alltrue([
      for email in var.budget_critical_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All budget critical emails must be valid email addresses."
  }
}

variable "budget_forecast_emails" {
  description = "Email addresses for budget forecast alerts"
  type        = list(string)
  default     = ["jq@aol.com"]
  
  validation {
    condition = alltrue([
      for email in var.budget_forecast_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All budget forecast emails must be valid email addresses."
  }
}

# Token Budget Configuration
variable "token_budget_threshold" {
  description = "Token budget alert threshold percentage"
  type        = number
  default     = 80
  
  validation {
    condition     = var.token_budget_threshold >= 0 && var.token_budget_threshold <= 100
    error_message = "Token budget threshold must be between 0 and 100."
  }
}

variable "token_budget_emails" {
  description = "Email addresses for token budget alerts"
  type        = list(string)
  default     = ["jq@aol.com"]
  
  validation {
    condition = alltrue([
      for email in var.token_budget_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All token budget emails must be valid email addresses."
  }
}

# Advanced Budget Configuration
variable "include_related_ai_services" {
  description = "Include related AI services (SageMaker, Comprehend, etc.) in budget monitoring"
  type        = bool
  default     = false
}

variable "budget_cost_filter_tags" {
  description = "Tag-based cost filters for budget monitoring"
  type        = map(list(string))
  default     = {}
}

# Budget Anomaly Detection
variable "enable_budget_anomaly_detection" {
  description = "Enable anomaly detection for budget monitoring"
  type        = bool
  default     = true
}

variable "budget_anomaly_threshold" {
  description = "Dollar threshold for budget anomaly detection"
  type        = number
  default     = 100
  
  validation {
    condition     = var.budget_anomaly_threshold >= 0
    error_message = "Budget anomaly threshold must be non-negative."
  }
}

variable "budget_anomaly_frequency" {
  description = "Frequency for budget anomaly notifications (DAILY, IMMEDIATE, WEEKLY)"
  type        = string
  default     = "DAILY"
  
  validation {
    condition     = contains(["DAILY", "IMMEDIATE", "WEEKLY"], var.budget_anomaly_frequency)
    error_message = "Budget anomaly frequency must be DAILY, IMMEDIATE, or WEEKLY."
  }
}

variable "budget_anomaly_emails" {
  description = "Email addresses for budget anomaly alerts"
  type        = list(string)
  default     = ["jq@aol.com"]
  
  validation {
    condition = alltrue([
      for email in var.budget_anomaly_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All budget anomaly emails must be valid email addresses."
  }
}

# Budget Auto-Adjustment
variable "budget_auto_adjust_type" {
  description = "Type of budget auto-adjustment (HISTORICAL, FORECAST, or null to disable)"
  type        = string
  default     = null
  
  validation {
    condition = var.budget_auto_adjust_type == null || contains([
      "HISTORICAL", "FORECAST"
    ], var.budget_auto_adjust_type)
    error_message = "Budget auto-adjust type must be HISTORICAL, FORECAST, or null."
  }
}

variable "budget_historical_adjustment_period" {
  description = "Number of budget periods for historical adjustments (1-60)"
  type        = number
  default     = 6
  
  validation {
    condition     = var.budget_historical_adjustment_period >= 1 && var.budget_historical_adjustment_period <= 60
    error_message = "Budget historical adjustment period must be between 1 and 60."
  }
}

# Token Anomaly Detection
variable "enable_token_anomaly_detection" {
  description = "Enable anomaly detection for token usage monitoring"
  type        = bool
  default     = true
}

variable "token_anomaly_threshold_value" {
  description = "Token usage anomaly threshold"
  type        = number
  default     = 1000
  
  validation {
    condition     = var.token_anomaly_threshold_value >= 0
    error_message = "Token anomaly threshold must be non-negative."
  }
}
