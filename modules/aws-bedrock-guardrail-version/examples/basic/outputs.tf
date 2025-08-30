output "guardrail_arn" {
  description = "The Amazon Resource Name (ARN) of the guardrail"
  value       = module.guardrail_version.guardrail_arn
}

output "version" {
  description = "The version number of the guardrail version"
  value       = module.guardrail_version.version
}

output "version_description" {
  description = "The description of the guardrail version"
  value       = module.guardrail_version.description
}

output "base_guardrail_id" {
  description = "The ID of the base guardrail"
  value       = module.bedrock_guardrail.guardrail_id
}
