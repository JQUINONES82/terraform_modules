/**
  * <!-- This will become the header in README.md
  *      Add a description of the module here.
  *      Do not include Variable or Output descriptions. -->
  * Comprehensive AWS IAM Role module that follows AWS best practices by using 
  * separate policy attachment resources instead of deprecated inline policy management
  * to provide better control and avoid resource conflicts.
  *
  */

# Create the IAM role
resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0

  name                  = var.name
  name_prefix           = var.name_prefix
  path                  = var.path
  description           = var.description
  assume_role_policy    = var.assume_role_policy
  force_detach_policies = var.force_detach_policies
  permissions_boundary  = var.permissions_boundary
  max_session_duration  = var.max_session_duration
  tags                  = var.tags

  # No deprecated inline_policy or managed_policy_arns
  # These are managed by separate resources for better control

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = var.name != null || var.name_prefix != null
      error_message = "Either name or name_prefix must be specified."
    }

    precondition {
      condition     = !(var.name != null && var.name_prefix != null)
      error_message = "name and name_prefix are mutually exclusive."
    }

    precondition {
      condition     = can(jsondecode(var.assume_role_policy))
      error_message = "assume_role_policy must be valid JSON."
    }
  }
}

# Attach managed policies
resource "aws_iam_role_policy_attachment" "managed" {
  for_each = var.create_role ? var.managed_policy_arns : []

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

# Create and attach inline policies
resource "aws_iam_role_policy" "inline" {
  for_each = var.create_role ? var.inline_policies : {}

  name   = each.key
  role   = aws_iam_role.this[0].id
  policy = each.value.policy

  lifecycle {
    precondition {
      condition     = can(jsondecode(each.value.policy))
      error_message = "Inline policy '${each.key}' must be valid JSON."
    }
  }
}

# Create instance profile if requested
resource "aws_iam_instance_profile" "this" {
  count = var.create_role && var.create_instance_profile ? 1 : 0

  name = var.instance_profile_name != null ? var.instance_profile_name : aws_iam_role.this[0].name
  path = var.instance_profile_path
  role = aws_iam_role.this[0].name
  tags = var.tags
}
