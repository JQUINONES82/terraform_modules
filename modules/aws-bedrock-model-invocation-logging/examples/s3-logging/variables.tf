variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-east-1"
}

variable "bucket_name_prefix" {
  type        = string
  description = "Prefix for the S3 bucket name"
  default     = "bedrock-logs"
}

variable "s3_key_prefix" {
  type        = string
  description = "S3 key prefix for Bedrock logs"
  default     = "bedrock-invocations"
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
