output "policy_arn" {
  description = "ARN of the policy created from data source"
  value       = module.data_source_policy.arn
}

output "policy_name" {
  description = "Name of the policy created from data source"
  value       = module.data_source_policy.name
}

output "policy_document" {
  description = "The combined policy document"
  value       = data.aws_iam_policy_document.combined.json
}

output "s3_policy_json" {
  description = "S3 access policy JSON"
  value       = data.aws_iam_policy_document.s3_access.json
}

output "cloudwatch_policy_json" {
  description = "CloudWatch access policy JSON"
  value       = data.aws_iam_policy_document.cloudwatch_access.json
}
