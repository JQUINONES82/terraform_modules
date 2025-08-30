/**
 * Outputs for AWS KMS Key module
 */

# Primary key outputs
output "key_id" {
  description = "The globally unique identifier for the key."
  value       = var.create_key ? aws_kms_key.this[0].key_id : null
}

output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the key."
  value       = var.create_key ? aws_kms_key.this[0].arn : null
}

output "key_usage" {
  description = "The cryptographic operations for which you can use the key."
  value       = var.create_key ? aws_kms_key.this[0].key_usage : null
}

output "key_spec" {
  description = "The type of key material in the CMK."
  value       = var.create_key ? aws_kms_key.this[0].customer_master_key_spec : null
}

output "description" {
  description = "The description of the key."
  value       = var.create_key ? aws_kms_key.this[0].description : null
}

output "enabled" {
  description = "Whether the key is enabled."
  value       = var.create_key ? aws_kms_key.this[0].is_enabled : null
}

output "enable_key_rotation" {
  description = "Whether key rotation is enabled."
  value       = var.create_key ? aws_kms_key.this[0].enable_key_rotation : null
}

output "multi_region" {
  description = "Whether the key is a multi-Region key."
  value       = var.create_key ? aws_kms_key.this[0].multi_region : null
}

output "policy" {
  description = "The key policy JSON document."
  value       = var.create_key ? aws_kms_key.this[0].policy : null
}

output "tags_all" {
  description = "A map of tags assigned to the resource."
  value       = var.create_key ? aws_kms_key.this[0].tags_all : null
}

# Alias outputs
output "alias_names" {
  description = "Map of alias names to their target key IDs."
  value = {
    for k, v in aws_kms_alias.this : k => {
      name          = v.name
      arn           = v.arn
      target_key_id = v.target_key_id
    }
  }
}

output "alias_arns" {
  description = "Map of alias ARNs."
  value = {
    for k, v in aws_kms_alias.this : k => v.arn
  }
}

# Grant outputs
output "grant_ids" {
  description = "Map of grant names to their IDs."
  value = {
    for k, v in aws_kms_grant.this : k => v.grant_id
  }
}

output "grant_tokens" {
  description = "Map of grant names to their tokens."
  value = {
    for k, v in aws_kms_grant.this : k => v.token
  }
}

# External key outputs
output "external_key_id" {
  description = "The globally unique identifier for the external key."
  value       = var.create_external_key ? aws_kms_external_key.this[0].id : null
}

output "external_key_arn" {
  description = "The Amazon Resource Name (ARN) of the external key."
  value       = var.create_external_key ? aws_kms_external_key.this[0].arn : null
}

output "external_key_usage" {
  description = "The cryptographic operations for which you can use the external key."
  value       = var.create_external_key ? aws_kms_external_key.this[0].key_usage : null
}

# External alias outputs
output "external_alias_names" {
  description = "Map of external alias names to their target key IDs."
  value = {
    for k, v in aws_kms_alias.external : k => {
      name          = v.name
      arn           = v.arn
      target_key_id = v.target_key_id
    }
  }
}

# Replica key outputs
output "replica_key_ids" {
  description = "Map of replica key names to their IDs."
  value = {
    for k, v in aws_kms_replica_key.this : k => v.key_id
  }
}

output "replica_key_arns" {
  description = "Map of replica key names to their ARNs."
  value = {
    for k, v in aws_kms_replica_key.this : k => v.arn
  }
}

# Convenience outputs
output "all_key_arns" {
  description = "List of all key ARNs (primary, external, and replicas)."
  value = compact(concat([
    var.create_key ? aws_kms_key.this[0].arn : null,
    var.create_external_key ? aws_kms_external_key.this[0].arn : null,
  ], values(aws_kms_replica_key.this)[*].arn))
}

output "all_key_ids" {
  description = "List of all key IDs (primary, external, and replicas)."
  value = compact(concat([
    var.create_key ? aws_kms_key.this[0].key_id : null,
    var.create_external_key ? aws_kms_external_key.this[0].id : null,
  ], values(aws_kms_replica_key.this)[*].key_id))
}
