variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-east-1"
}

variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "bedrock-hybrid"
}

variable "bucket_name_prefix" {
  type        = string
  description = "Prefix for S3 bucket names"
  default     = "bedrock-hybrid"
}

variable "log_group_name" {
  type        = string
  description = "CloudWatch log group name for Bedrock logs"
  default     = "/aws/bedrock/model-invocations-hybrid"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in CloudWatch"
  default     = 30
}

variable "s3_key_prefix" {
  type        = string
  description = "S3 key prefix for standard logs"
  default     = "bedrock-logs"
}

variable "large_data_key_prefix" {
  type        = string
  description = "S3 key prefix for large data logs"
  default     = "bedrock-large-data"
}

variable "enable_embedding_data" {
  type        = bool
  description = "Enable logging of embedding data"
  default     = true
}

variable "enable_image_data" {
  type        = bool
  description = "Enable logging of image data"
  default     = true
}

variable "enable_text_data" {
  type        = bool
  description = "Enable logging of text data"
  default     = true
}

variable "enable_video_data" {
  type        = bool
  description = "Enable logging of video data"
  default     = true
}
