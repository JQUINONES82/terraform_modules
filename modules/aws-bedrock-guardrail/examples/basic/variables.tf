variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-east-1"
}

variable "guardrail_name" {
  type        = string
  description = "Name of the Bedrock guardrail"
  default     = "example-guardrail"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    Environment = "example"
    Project     = "bedrock-guardrail-demo"
  }
}
