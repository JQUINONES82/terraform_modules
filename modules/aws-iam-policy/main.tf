/**
  * <!-- This will become the header in README.md
  *      Add a description of the module here.
  *      Do not include Variable or Output descriptions. -->
  * Comprehensive AWS IAM Policy module that supports all IAM policy features
  * including customer managed policies, policy versions, and policy attachments.
  * Follows AWS best practices for policy management and includes comprehensive
  * validation and lifecycle management.
  *
  */

# Create the IAM policy
resource "aws_iam_policy" "this" {
  count = var.create_policy ? 1 : 0

  name        = var.name
  name_prefix = var.name_prefix
  path        = var.path
  description = var.description
  policy      = var.policy

  tags = var.tags

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
      condition     = can(jsondecode(var.policy))
      error_message = "policy must be valid JSON."
    }

    precondition {
      condition     = length(var.policy) <= 6144
      error_message = "Policy document cannot exceed 6144 characters."
    }
  }
}

# Attach policy to roles
resource "aws_iam_role_policy_attachment" "role_attachments" {
  for_each = var.create_policy ? toset(var.attach_to_roles) : []

  role       = each.value
  policy_arn = aws_iam_policy.this[0].arn
}

# Attach policy to users
resource "aws_iam_user_policy_attachment" "user_attachments" {
  for_each = var.create_policy ? toset(var.attach_to_users) : []

  user       = each.value
  policy_arn = aws_iam_policy.this[0].arn
}

# Attach policy to groups
resource "aws_iam_group_policy_attachment" "group_attachments" {
  for_each = var.create_policy ? toset(var.attach_to_groups) : []

  group      = each.value
  policy_arn = aws_iam_policy.this[0].arn
}
