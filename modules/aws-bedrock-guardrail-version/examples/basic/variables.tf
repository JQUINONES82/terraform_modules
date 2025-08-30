variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-east-1"
}

variable "guardrail_name" {
  type        = string
  description = "Base name for the Bedrock guardrail"
  default     = "example-guardrail"
}

variable "version_description" {
  type        = string
  description = "Description for the guardrail version"
  default     = "Basic example version with hate speech filtering"
}

variable "skip_destroy" {
  type        = bool
  description = "Whether to retain the version during destroy operations"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    Environment = "example"
    Project     = "bedrock-guardrail-version-demo"
  }
}
