/**
  * <!-- This will become the header in README.md
  *      Add a description of the module here.
  *      Do not include Variable or Output descriptions. -->
  * Comprehensive AWS KMS Key module that supports all KMS key features
  * including customer managed keys, key policies, grants, aliases, and
  * key rotation. Follows AWS best practices for encryption key management
  * and includes comprehensive validation and lifecycle management.
  *
  */

# Create the KMS key
resource "aws_kms_key" "this" {
  count = var.create_key ? 1 : 0

  description                        = var.description
  key_usage                          = var.key_usage
  customer_master_key_spec           = var.key_spec
  policy                             = var.policy
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  deletion_window_in_days            = var.deletion_window_in_days
  enable_key_rotation                = var.enable_key_rotation
  rotation_period_in_days            = var.rotation_period_in_days
  multi_region                       = var.multi_region
  is_enabled                         = var.is_enabled

  tags = var.tags

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = var.policy == null || can(jsondecode(var.policy))
      error_message = "Key policy must be valid JSON when specified."
    }

    precondition {
      condition     = var.key_usage == "ENCRYPT_DECRYPT" || var.enable_key_rotation == false
      error_message = "Key rotation can only be enabled for ENCRYPT_DECRYPT keys."
    }

    precondition {
      condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
      error_message = "Deletion window must be between 7 and 30 days."
    }
  }
}

# Create key aliases
resource "aws_kms_alias" "this" {
  for_each = var.create_key && var.enable_alias ? var.aliases : {}

  name          = startswith(each.key, "alias/") ? each.key : "alias/${each.key}"
  target_key_id = aws_kms_key.this[0].key_id

  lifecycle {
    create_before_destroy = true
  }
}

# Create key grants
resource "aws_kms_grant" "this" {
  for_each = var.create_key && var.enable_grants ? var.grants : {}

  name              = each.key
  key_id            = aws_kms_key.this[0].key_id
  grantee_principal = each.value.grantee_principal
  operations        = each.value.operations

  dynamic "constraints" {
    for_each = each.value.constraints != null ? [each.value.constraints] : []
    content {
      encryption_context_equals = constraints.value.encryption_context_equals
      encryption_context_subset = constraints.value.encryption_context_subset
    }
  }

  retiring_principal = each.value.retiring_principal

  lifecycle {
    create_before_destroy = true
  }
}

# External key for imported key material (if specified)
resource "aws_kms_external_key" "this" {
  count = var.create_external_key ? 1 : 0

  description                        = var.description
  policy                             = var.policy
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  deletion_window_in_days            = var.deletion_window_in_days
  key_material_base64                = var.key_material_base64
  valid_to                           = var.valid_to
  multi_region                       = var.multi_region

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# External key aliases
resource "aws_kms_alias" "external" {
  for_each = var.create_external_key && var.enable_alias ? var.aliases : {}

  name          = startswith(each.key, "alias/") ? each.key : "alias/${each.key}"
  target_key_id = aws_kms_external_key.this[0].id

  lifecycle {
    create_before_destroy = true
  }
}

# Replica key for multi-region keys
resource "aws_kms_replica_key" "this" {
  for_each = var.enable_replica_keys ? var.replica_keys : {}

  description                        = var.description
  primary_key_arn                    = each.value.primary_key_arn
  policy                             = each.value.policy
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  deletion_window_in_days            = var.deletion_window_in_days

  tags = merge(var.tags, each.value.tags)

  lifecycle {
    create_before_destroy = true
  }
}
