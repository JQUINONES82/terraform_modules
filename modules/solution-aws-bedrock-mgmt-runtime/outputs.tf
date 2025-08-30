/**
 * Outputs for Aoutput "logs_bucket_id" {
  descrioutput "bedrock_logging_output "management_security_group_id" {
  description = "ID of the security group for Bedrock management endpoint"
  value       = module.bedrock_management_sg.id
}

output "runtime_security_group_id" {
  description = "ID of the security group for Bedrock runtime endpoint"
  value       = module.bedrock_runtime_sg.id
}

output "general_security_group_id" {
  description = "ID of the security group for general Bedrock endpoints"
  value       = module.bedrock_general_sg.id
} description = "ARN of the IAM role used for Bedrock logging"
  value       = module.bedrock_logging_role.arn
}

output "bedrock_logging_role_name" {
  description = "Name of the IAM role used for Bedrock logging"
  value       = module.bedrock_logging_role.name
}ID of the S3 bucket used for Bedrock logs"
  value       = module.bedrock_logs_bucket.id
}

output "logs_bucket_arn" {
  description = "ARN of the S3 bucket used for Bedrock logs"
  value       = module.bedrock_logs_bucket.arn
}k Management Runtime Solution
 */

# KMS Key outputs
output "kms_key_id" {
  description = "The KMS key ID used for Bedrock encryption"
  value       = module.bedrock_kms_key.key_id
}

output "kms_key_arn" {
  description = "The KMS key ARN used for Bedrock encryption"
  value       = module.bedrock_kms_key.key_arn
}

output "kms_key_alias" {
  description = "The KMS key alias"
  value       = module.bedrock_kms_key.alias_names
}

# S3 Bucket outputs
output "logs_bucket_id" {
  description = "The ID of the S3 bucket for Bedrock logs"
  value       = module.bedrock_logs_bucket.id
}

output "logs_bucket_arn" {
  description = "The ARN of the S3 bucket for Bedrock logs"
  value       = module.bedrock_logs_bucket.arn
}

output "logs_bucket_domain_name" {
  description = "The domain name of the S3 bucket for Bedrock logs"
  value       = module.bedrock_logs_bucket.bucket_domain_name
}

# CloudWatch Log Group outputs
output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Bedrock invocations"
  value       = aws_cloudwatch_log_group.bedrock_invocations.name
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group for Bedrock invocations"
  value       = aws_cloudwatch_log_group.bedrock_invocations.arn
}

# IAM Role outputs
output "bedrock_logging_role_arn" {
  description = "The ARN of the IAM role used for Bedrock logging"
  value       = module.bedrock_logging_role.arn
}

output "bedrock_logging_role_name" {
  description = "The name of the IAM role used for Bedrock logging"
  value       = module.bedrock_logging_role.name
}

output "bedrock_logging_policy_arn" {
  description = "The ARN of the IAM policy for Bedrock logging"
  value       = module.bedrock_logging_policy.arn
}

# Security Group outputs
output "management_security_group_id" {
  description = "The ID of the security group for Bedrock management endpoint"
  value       = module.bedrock_management_sg.id
}

output "runtime_security_group_id" {
  description = "The ID of the security group for Bedrock runtime endpoint"
  value       = module.bedrock_runtime_sg.id
}

output "general_security_group_id" {
  description = "The ID of the security group for general Bedrock endpoints"
  value       = module.bedrock_general_sg.id
}

# VPC Endpoint outputs
output "bedrock_management_endpoint_id" {
  description = "The ID of the Bedrock management VPC endpoint"
  value       = var.enable_bedrock_management_endpoint ? module.bedrock_management_endpoint[0].vpc_endpoint_id : null
}

output "bedrock_management_endpoint_dns_entries" {
  description = "The DNS entries for the Bedrock management VPC endpoint"
  value       = var.enable_bedrock_management_endpoint ? module.bedrock_management_endpoint[0].dns_entry : null
}

output "bedrock_runtime_endpoint_id" {
  description = "The ID of the Bedrock runtime VPC endpoint"
  value       = var.enable_bedrock_runtime_endpoint ? module.bedrock_runtime_endpoint[0].vpc_endpoint_id : null
}

output "bedrock_runtime_endpoint_dns_entries" {
  description = "The DNS entries for the Bedrock runtime VPC endpoint"
  value       = var.enable_bedrock_runtime_endpoint ? module.bedrock_runtime_endpoint[0].dns_entry : null
}

output "bedrock_agent_endpoint_id" {
  description = "The ID of the Bedrock agent VPC endpoint"
  value       = var.enable_bedrock_agent_endpoint ? module.bedrock_agent_endpoint[0].vpc_endpoint_id : null
}

output "bedrock_agent_runtime_endpoint_id" {
  description = "The ID of the Bedrock agent runtime VPC endpoint"
  value       = var.enable_bedrock_agent_runtime_endpoint ? module.bedrock_agent_runtime_endpoint[0].vpc_endpoint_id : null
}

# Guardrail outputs
output "bedrock_guardrail_id" {
  description = "The ID of the Bedrock guardrail"
  value       = var.enable_guardrails ? module.bedrock_guardrail[0].guardrail_id : null
}

output "bedrock_guardrail_arn" {
  description = "The ARN of the Bedrock guardrail"
  value       = var.enable_guardrails ? module.bedrock_guardrail[0].guardrail_arn : null
}

output "bedrock_guardrail_version" {
  description = "The version of the Bedrock guardrail"
  value       = var.enable_guardrails ? module.bedrock_guardrail[0].version : null
}

# Model Invocation Logging outputs
output "model_invocation_logging_enabled" {
  description = "Whether model invocation logging is enabled"
  value       = var.enable_model_invocation_logging
}

# Solution metadata
output "solution_name" {
  description = "The name of the deployed solution"
  value       = "bedrock-mgmt-runtime"
}

output "environment" {
  description = "The environment where the solution is deployed"
  value       = var.environment
}

output "region" {
  description = "The AWS region where the solution is deployed"
  value       = local.region
}

output "account_id" {
  description = "The AWS account ID where the solution is deployed"
  value       = local.account_id
}

output "resource_prefix" {
  description = "The resource prefix used for naming"
  value       = local.resource_prefix
}

# Security compliance outputs
output "encryption_in_transit_enabled" {
  description = "Whether encryption in transit is enforced"
  value       = true
}

output "encryption_at_rest_enabled" {
  description = "Whether encryption at rest is enabled"
  value       = true
}

output "kms_customer_managed_keys_used" {
  description = "Whether customer-managed KMS keys are used"
  value       = true
}

output "vpc_endpoints_private_dns_enabled" {
  description = "Whether private DNS is enabled for VPC endpoints"
  value       = var.enable_private_dns
}

output "guardrails_pii_protection_enabled" {
  description = "Whether PII protection is enabled in guardrails"
  value       = var.enable_guardrails
}

output "network_segmentation_implemented" {
  description = "Whether network segmentation is implemented"
  value       = true
}

# Summary output for easy reference
output "solution_summary" {
  description = "Summary of the deployed Bedrock solution"
  value = {
    kms_key_arn            = module.bedrock_kms_key.key_arn
    logs_bucket_name       = module.bedrock_logs_bucket.id
    cloudwatch_log_group   = aws_cloudwatch_log_group.bedrock_invocations.name
    logging_role_arn       = module.bedrock_logging_role.arn
    guardrail_id           = var.enable_guardrails ? module.bedrock_guardrail[0].guardrail_id : null
    management_endpoint_id = var.enable_bedrock_management_endpoint ? module.bedrock_management_endpoint[0].vpc_endpoint_id : null
    runtime_endpoint_id    = var.enable_bedrock_runtime_endpoint ? module.bedrock_runtime_endpoint[0].vpc_endpoint_id : null
    security_groups = {
      management = module.bedrock_management_sg.id
      runtime    = module.bedrock_runtime_sg.id
      general    = module.bedrock_general_sg.id
    }
  }
}
