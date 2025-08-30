output "logging_configuration_id" {
  description = "The ID of the logging configuration (AWS region)"
  value       = module.bedrock_logging_hybrid.id
}

# S3 outputs
output "s3_logs_bucket_name" {
  description = "Name of the S3 bucket for standard logs"
  value       = aws_s3_bucket.bedrock_logs.bucket
}

output "s3_logs_bucket_arn" {
  description = "ARN of the S3 bucket for standard logs"
  value       = aws_s3_bucket.bedrock_logs.arn
}

output "s3_large_data_bucket_name" {
  description = "Name of the S3 bucket for large data"
  value       = aws_s3_bucket.bedrock_large_data.bucket
}

output "s3_large_data_bucket_arn" {
  description = "ARN of the S3 bucket for large data"
  value       = aws_s3_bucket.bedrock_large_data.arn
}

# CloudWatch outputs
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.bedrock_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.bedrock_logs.arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role used for CloudWatch logging"
  value       = aws_iam_role.bedrock_cloudwatch.arn
}

# Configuration outputs
output "data_delivery_settings" {
  description = "Summary of data delivery settings"
  value       = module.bedrock_logging_hybrid.data_delivery_settings
}

output "s3_configuration" {
  description = "S3 configuration details"
  value = {
    logs_bucket      = aws_s3_bucket.bedrock_logs.bucket
    large_data_bucket = aws_s3_bucket.bedrock_large_data.bucket
    logs_key_prefix  = var.s3_key_prefix
    large_data_key_prefix = var.large_data_key_prefix
  }
}

output "cloudwatch_configuration" {
  description = "CloudWatch configuration details"
  value = {
    log_group_name    = aws_cloudwatch_log_group.bedrock_logs.name
    retention_days    = var.log_retention_days
    role_arn         = aws_iam_role.bedrock_cloudwatch.arn
  }
}
