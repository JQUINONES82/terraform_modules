output "base_guardrail_arn" {
  description = "The Amazon Resource Name (ARN) of the base guardrail"
  value       = module.bedrock_guardrail.guardrail_arn
}

output "base_guardrail_id" {
  description = "The ID of the base guardrail"
  value       = module.bedrock_guardrail.guardrail_id
}

output "dev_version" {
  description = "The development version number"
  value       = module.guardrail_version_dev.version
}

output "staging_version" {
  description = "The staging version number"
  value       = module.guardrail_version_staging.version
}

output "prod_version" {
  description = "The production version number"
  value       = module.guardrail_version_prod.version
}

output "dev_version_id" {
  description = "The development version ID"
  value       = module.guardrail_version_dev.id
}

output "staging_version_id" {
  description = "The staging version ID"
  value       = module.guardrail_version_staging.id
}

output "prod_version_id" {
  description = "The production version ID"
  value       = module.guardrail_version_prod.id
}
