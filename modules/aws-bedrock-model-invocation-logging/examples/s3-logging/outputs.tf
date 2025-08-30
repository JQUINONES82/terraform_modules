output "logging_configuration_id" {
  description = "The ID of the logging configuration (AWS region)"
  value       = module.bedrock_logging.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket used for logging"
  value       = aws_s3_bucket.bedrock_logs.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket used for logging"
  value       = aws_s3_bucket.bedrock_logs.arn
}

output "s3_key_prefix" {
  description = "S3 key prefix used for logs"
  value       = module.bedrock_logging.s3_key_prefix
}

output "data_delivery_settings" {
  description = "Summary of data delivery settings"
  value       = module.bedrock_logging.data_delivery_settings
}

output "account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region where logging is configured"
  value       = var.aws_region
}
