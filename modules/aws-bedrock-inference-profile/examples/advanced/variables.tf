variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-west-2"
}

variable "project_name" {
  type        = string
  description = "Base name for the project and inference profiles"
  default     = "advanced-ai-project"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all inference profiles"
  default = {
    Project     = "advanced-ai-project"
    Team        = "ai-platform"
    CostCenter  = "engineering"
    Department  = "ai-research"
    ManagedBy   = "terraform"
  }
}

variable "enable_cross_account_profile" {
  type        = bool
  description = "Whether to create a cross-account inference profile"
  default     = false
}

variable "cross_account_id" {
  type        = string
  description = "AWS account ID for cross-account inference profile"
  default     = "123456789012"
}

variable "cross_account_region" {
  type        = string
  description = "AWS region for cross-account inference profile"
  default     = "eu-central-1"
}

variable "cross_account_profile_id" {
  type        = string
  description = "Inference profile ID in the cross-account setup"
  default     = "eu.anthropic.claude-3-5-sonnet-20240620-v1:0"
}
