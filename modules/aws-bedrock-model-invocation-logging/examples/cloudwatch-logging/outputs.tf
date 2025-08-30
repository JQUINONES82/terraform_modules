output "logging_configuration_id" {
  description = "The ID of the logging configuration (AWS region)"
  value       = module.bedrock_logging.id
}

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

output "iam_role_name" {
  description = "Name of the IAM role used for CloudWatch logging"
  value       = aws_iam_role.bedrock_cloudwatch.name
}

output "data_delivery_settings" {
  description = "Summary of data delivery settings"
  value       = module.bedrock_logging.data_delivery_settings
}

output "log_retention_days" {
  description = "Log retention period in days"
  value       = var.log_retention_days
}
