variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "owner" {
  description = "Owner of the budget"
  type        = string
  default     = "finance-team"
}

variable "monthly_limit" {
  description = "Monthly budget limit in USD"
  type        = string
  default     = "1000"
}

variable "bedrock_limit" {
  description = "Bedrock service budget limit in USD"
  type        = string
  default     = "200"
}

variable "notification_email" {
  description = "Email address for budget notifications"
  type        = string
  default     = "admin@company.com"
}
