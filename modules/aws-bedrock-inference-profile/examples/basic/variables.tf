variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-west-2"
}

variable "profile_name" {
  type        = string
  description = "Name of the Bedrock inference profile"
  default     = "example-claude-profile"
}

variable "profile_description" {
  type        = string
  description = "Description of the inference profile"
  default     = "Basic example inference profile for Claude Sonnet"
}

variable "model_arn" {
  type        = string
  description = "ARN of the foundation model to use"
  default     = "arn:aws:bedrock:us-west-2::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    Environment = "example"
    Project     = "bedrock-inference-profile-demo"
    Team        = "ai-platform"
  }
}
