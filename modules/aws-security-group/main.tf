/**
  * <!-- This will become the header in README.md
  *      Add a description of the module here.
  *      Do not include Variable or Output descriptions. -->
  * Comprehensive AWS Security Group module that follows AWS best practices by using 
  * separate ingress and egress rule resources instead of inline rules to avoid conflicts
  * and provide better management of complex security group configurations.
  *
  */

# Create the security group
resource "aws_security_group" "this" {
  name                   = var.name
  name_prefix            = var.name_prefix
  description            = var.description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.revoke_rules_on_delete
  tags                   = var.tags

  # No inline ingress/egress rules to avoid conflicts with separate rule resources
  # This follows AWS and Terraform best practices

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }

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
  }
}

# Create ingress rules using the modern approach
resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }

  security_group_id = aws_security_group.this.id
  description       = each.value.description

  # Protocol and port configuration
  ip_protocol = each.value.ip_protocol
  from_port   = each.value.from_port
  to_port     = each.value.to_port

  # Source configuration (exactly one must be specified)
  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id

  tags = merge(var.tags, each.value.tags)
}

# Create egress rules using the modern approach
resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for idx, rule in var.egress_rules : idx => rule }

  security_group_id = aws_security_group.this.id
  description       = each.value.description

  # Protocol and port configuration
  ip_protocol = each.value.ip_protocol
  from_port   = each.value.from_port
  to_port     = each.value.to_port

  # Destination configuration (exactly one must be specified)
  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id

  tags = merge(var.tags, each.value.tags)
}
