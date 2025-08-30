/**
  * <!-- This will become the header in README.md
  *      Add a description of the module here.
  *      Do not include Variable or Output descriptions. -->
  * Comprehensive AWS VPC Endpoint module that supports all endpoint types including Gateway, Interface, 
  * GatewayLoadBalancer, Resource, and ServiceNetwork endpoints with full configuration options.
  *
  */

resource "aws_vpc_endpoint" "this" {
  vpc_id                = var.vpc_id
  auto_accept           = var.auto_accept
  policy                = var.policy
  private_dns_enabled   = var.private_dns_enabled
  ip_address_type       = var.ip_address_type
  route_table_ids       = var.route_table_ids
  subnet_ids            = var.subnet_ids
  security_group_ids    = var.security_group_ids
  vpc_endpoint_type     = var.vpc_endpoint_type
  tags                  = var.tags

  # Exactly one of these three is required
  service_name              = var.service_name
  resource_configuration_arn = var.resource_configuration_arn
  service_network_arn       = var.service_network_arn
  service_region            = var.service_region

  dynamic "dns_options" {
    for_each = var.dns_options != null ? [var.dns_options] : []
    content {
      dns_record_ip_type                             = dns_options.value.dns_record_ip_type
      private_dns_only_for_inbound_resolver_endpoint = dns_options.value.private_dns_only_for_inbound_resolver_endpoint
    }
  }

  dynamic "subnet_configuration" {
    for_each = var.subnet_configurations
    content {
      ipv4      = subnet_configuration.value.ipv4
      ipv6      = subnet_configuration.value.ipv6
      subnet_id = subnet_configuration.value.subnet_id
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    precondition {
      condition = (
        (var.service_name != null ? 1 : 0) +
        (var.resource_configuration_arn != null ? 1 : 0) +
        (var.service_network_arn != null ? 1 : 0)
      ) == 1
      error_message = "Exactly one of service_name, resource_configuration_arn, or service_network_arn must be specified."
    }

    precondition {
      condition = var.vpc_endpoint_type != "Gateway" || var.subnet_ids == null
      error_message = "subnet_ids cannot be specified for Gateway endpoints."
    }

    precondition {
      condition = var.vpc_endpoint_type == "Gateway" || var.route_table_ids == null
      error_message = "route_table_ids can only be specified for Gateway endpoints."
    }

    precondition {
      condition = var.vpc_endpoint_type == "Interface" || var.private_dns_enabled == null
      error_message = "private_dns_enabled can only be specified for Interface endpoints."
    }

    precondition {
      condition = (
        var.vpc_endpoint_type == "Interface" || 
        var.vpc_endpoint_type == "GatewayLoadBalancer" ||
        var.security_group_ids == null
      )
      error_message = "security_group_ids can only be specified for Interface and GatewayLoadBalancer endpoints."
    }
  }
}
