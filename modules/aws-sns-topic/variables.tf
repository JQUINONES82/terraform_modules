# Core variables
variable "create_topic" {
  description = "Whether to create the SNS topic"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the SNS topic. If omitted, Terraform will assign a random, unique name"
  type        = string
  default     = null

  validation {
    condition = var.name == null || (
      length(var.name) >= 1 &&
      length(var.name) <= 256 &&
      can(regex("^[a-zA-Z0-9_-]+$", var.name))
    )
    error_message = "Topic name must be 1-256 characters and can contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with name"
  type        = string
  default     = null

  validation {
    condition = var.name_prefix == null || (
      try(length(var.name_prefix), 0) >= 1 &&
      try(length(var.name_prefix), 0) <= 256 &&
      can(regex("^[a-zA-Z0-9_-]+$", var.name_prefix))
    )
    error_message = "Topic name prefix must be 1-256 characters and can contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "display_name" {
  description = "The display name for the topic"
  type        = string
  default     = null

  validation {
    condition = var.display_name == null || (
      length(var.display_name) >= 1 &&
      length(var.display_name) <= 100
    )
    error_message = "Display name must be 1-100 characters."
  }
}

# Policy variables
variable "policy" {
  description = "The fully-formed AWS policy as JSON"
  type        = string
  default     = null

  validation {
    condition = var.policy == null || can(jsondecode(var.policy))
    error_message = "Policy must be valid JSON."
  }
}

variable "delivery_policy" {
  description = "The delivery policy for the topic"
  type        = string
  default     = null

  validation {
    condition = var.delivery_policy == null || can(jsondecode(var.delivery_policy))
    error_message = "Delivery policy must be valid JSON."
  }
}

# Feedback role ARNs
variable "application_success_feedback_role_arn" {
  description = "The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "application_success_feedback_sample_rate" {
  description = "Percentage of success to sample"
  type        = number
  default     = null

  validation {
    condition = var.application_success_feedback_sample_rate == null || (
      var.application_success_feedback_sample_rate >= 0 &&
      var.application_success_feedback_sample_rate <= 100
    )
    error_message = "Sample rate must be between 0 and 100."
  }
}

variable "application_failure_feedback_role_arn" {
  description = "IAM role for failure feedback"
  type        = string
  default     = null
}

variable "firehose_success_feedback_role_arn" {
  description = "The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "firehose_success_feedback_sample_rate" {
  description = "Percentage of success to sample"
  type        = number
  default     = null

  validation {
    condition = var.firehose_success_feedback_sample_rate == null || (
      var.firehose_success_feedback_sample_rate >= 0 &&
      var.firehose_success_feedback_sample_rate <= 100
    )
    error_message = "Sample rate must be between 0 and 100."
  }
}

variable "firehose_failure_feedback_role_arn" {
  description = "IAM role for failure feedback"
  type        = string
  default     = null
}

variable "http_success_feedback_role_arn" {
  description = "The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "http_success_feedback_sample_rate" {
  description = "Percentage of success to sample"
  type        = number
  default     = null

  validation {
    condition = var.http_success_feedback_sample_rate == null || (
      var.http_success_feedback_sample_rate >= 0 &&
      var.http_success_feedback_sample_rate <= 100
    )
    error_message = "Sample rate must be between 0 and 100."
  }
}

variable "http_failure_feedback_role_arn" {
  description = "IAM role for failure feedback"
  type        = string
  default     = null
}

variable "lambda_success_feedback_role_arn" {
  description = "The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "lambda_success_feedback_sample_rate" {
  description = "Percentage of success to sample"
  type        = number
  default     = null

  validation {
    condition = var.lambda_success_feedback_sample_rate == null || (
      var.lambda_success_feedback_sample_rate >= 0 &&
      var.lambda_success_feedback_sample_rate <= 100
    )
    error_message = "Sample rate must be between 0 and 100."
  }
}

variable "lambda_failure_feedback_role_arn" {
  description = "IAM role for failure feedback"
  type        = string
  default     = null
}

variable "sqs_success_feedback_role_arn" {
  description = "The IAM role permitted to receive success feedback for this topic"
  type        = string
  default     = null
}

variable "sqs_success_feedback_sample_rate" {
  description = "Percentage of success to sample"
  type        = number
  default     = null

  validation {
    condition = var.sqs_success_feedback_sample_rate == null || (
      var.sqs_success_feedback_sample_rate >= 0 &&
      var.sqs_success_feedback_sample_rate <= 100
    )
    error_message = "Sample rate must be between 0 and 100."
  }
}

variable "sqs_failure_feedback_role_arn" {
  description = "IAM role for failure feedback"
  type        = string
  default     = null
}

# Encryption and security
variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS"
  type        = string
  default     = null
}

variable "fifo_topic" {
  description = "Boolean indicating whether or not to create a FIFO (first-in-first-out) topic"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO topics"
  type        = bool
  default     = null
}

variable "archive_policy" {
  description = "Message archive policy for the topic"
  type        = string
  default     = null

  validation {
    condition = var.archive_policy == null || can(jsondecode(var.archive_policy))
    error_message = "Archive policy must be valid JSON."
  }
}

variable "signature_version" {
  description = "If SignatureVersion should be 1 (SHA1) or 2 (SHA256)"
  type        = number
  default     = null

  validation {
    condition = var.signature_version == null || contains([1, 2], var.signature_version)
    error_message = "Signature version must be 1 or 2."
  }
}

variable "tracing_config" {
  description = "Tracing mode of an Amazon SNS topic"
  type        = string
  default     = null

  validation {
    condition = var.tracing_config == null || contains(["PassThrough", "Active"], var.tracing_config)
    error_message = "Tracing config must be 'PassThrough' or 'Active'."
  }
}

# Subscriptions
variable "subscriptions" {
  description = "Map of subscription configurations"
  type = map(object({
    protocol                        = string
    endpoint                        = string
    endpoint_auto_confirms          = optional(bool)
    confirmation_timeout_in_minutes = optional(number)
    raw_message_delivery           = optional(bool)
    filter_policy                  = optional(string)
    filter_policy_scope            = optional(string)
    delivery_policy                = optional(string)
    redrive_policy                 = optional(string)
    replay_policy                  = optional(string)
    subscription_role_arn          = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for sub in values(var.subscriptions) : contains([
        "sqs", "sms", "email", "email-json", "http", "https", 
        "application", "lambda", "firehose"
      ], sub.protocol)
    ])
    error_message = "Protocol must be one of: sqs, sms, email, email-json, http, https, application, lambda, firehose."
  }
}

# Topic Policy
variable "create_topic_policy" {
  description = "Whether to create a topic policy"
  type        = bool
  default     = false
}

variable "topic_policy" {
  description = "The fully-formed AWS policy as JSON for the topic"
  type        = string
  default     = null

  validation {
    condition = var.topic_policy == null || can(jsondecode(var.topic_policy))
    error_message = "Topic policy must be valid JSON."
  }
}

variable "topic_policy_principals" {
  description = "List of principals for the topic policy"
  type        = list(string)
  default     = ["*"]
}

variable "topic_policy_actions" {
  description = "List of actions for the topic policy"
  type        = list(string)
  default     = ["SNS:Publish", "SNS:Subscribe"]
}

variable "topic_policy_conditions" {
  description = "List of conditions for the topic policy"
  type = list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  default = []
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
