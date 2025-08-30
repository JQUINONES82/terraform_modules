variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-east-1"
}

variable "guardrail_name" {
  type        = string
  description = "Base name for the Bedrock guardrail"
  default     = "advanced-guardrail"
}

variable "dev_version_description" {
  type        = string
  description = "Description for the development version"
  default     = "Testing new content filtering policies"
}

variable "staging_version_description" {
  type        = string
  description = "Description for the staging version"
  default     = "Pre-production validation with enhanced PII detection"
}

variable "prod_version_description" {
  type        = string
  description = "Description for the production version"
  default     = "Stable release with comprehensive content policies"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    Environment = "multi-env"
    Project     = "bedrock-guardrail-advanced"
    Purpose     = "version-management"
  }
}
