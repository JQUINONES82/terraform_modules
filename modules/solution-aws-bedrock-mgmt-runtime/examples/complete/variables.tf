# Variables for the complete Bedrock management runtime example

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "bedrock-mgmt"
}

variable "vpc_id" {
  description = "VPC ID where the Bedrock runtime will be deployed"
  type        = string
  # This should be provided by the user - no default value
}

variable "subnet_ids" {
  description = "List of subnet IDs for VPC endpoint placement"
  type        = list(string)
  # This should be provided by the user - no default value
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "management_allowed_cidrs" {
  description = "CIDR blocks allowed to access Bedrock management endpoints"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "runtime_allowed_cidrs" {
  description = "CIDR blocks allowed to access Bedrock runtime endpoints"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "bedrock_role_name" {
  description = "Name for the Bedrock IAM role"
  type        = string
  default     = "bedrock-runtime-role"
}

variable "allowed_principals" {
  description = "List of AWS principals allowed to access Bedrock resources"
  type        = list(string)
  default     = []
}

variable "enable_guardrails" {
  description = "Enable Bedrock guardrails for content filtering"
  type        = bool
  default     = true
}

variable "enable_model_invocation_logging" {
  description = "Enable model invocation logging"
  type        = bool
  default     = true
}

variable "enable_cloudtrail_logging" {
  description = "Enable CloudTrail logging for API calls"
  type        = bool
  default     = true
}

variable "data_residency_region" {
  description = "Region for data residency compliance"
  type        = string
  default     = null
}

variable "compliance_framework" {
  description = "Compliance framework (SOC2, HIPAA, PCI, etc.)"
  type        = string
  default     = "SOC2"
}

variable "retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    "Terraform"   = "true"
    "Environment" = "dev"
    "Project"     = "bedrock-mgmt-runtime"
    "Owner"       = "Platform Team"
  }
}

# Extended Monitoring Configuration
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

# Threshold Configuration
variable "agents_error_threshold" {
  description = "Threshold for Bedrock Agents error alarms"
  type        = number
  default     = 5
}

variable "kb_error_threshold" {
  description = "Threshold for Knowledge Base error alarms"
  type        = number
  default     = 5
}

variable "agents_throttle_threshold" {
  description = "Threshold for Bedrock Agents throttling alarm"
  type        = number
  default     = 10
}

variable "kb_throttle_threshold" {
  description = "Threshold for Knowledge Base throttling alarm"
  type        = number
  default     = 10
}

variable "agents_latency_threshold_ms" {
  description = "Threshold for Bedrock Agents latency alarm in milliseconds"
  type        = number
  default     = 15000
}

variable "kb_latency_threshold_ms" {
  description = "Threshold for Knowledge Base retrieval latency alarm in milliseconds"
  type        = number
  default     = 5000
}

variable "guardrails_blocked_threshold" {
  description = "Threshold for guardrails blocked inputs/outputs alarm"
  type        = number
  default     = 50
}

variable "training_job_failure_threshold" {
  description = "Threshold for training job failures alarm"
  type        = number
  default     = 0
}

# SNS Configuration for Extended Monitoring
variable "agents_alert_subscriptions" {
  description = "SNS subscriptions for Bedrock Agents alerts"
  type = map(object({
    protocol = string
    endpoint = string
  }))
  default = {}
}

variable "kb_alert_subscriptions" {
  description = "SNS subscriptions for Knowledge Base alerts"
  type = map(object({
    protocol = string
    endpoint = string
  }))
  default = {}
}

variable "guardrails_alert_subscriptions" {
  description = "SNS subscriptions for Guardrails alerts"
  type = map(object({
    protocol = string
    endpoint = string
  }))
  default = {}
}
