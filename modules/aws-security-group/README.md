# aws-security-group

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

This module creates AWS Security Groups using modern best practices with separate ingress and egress rule resources to avoid conflicts and provide better management of complex security group configurations.

## Features

- **Modern Architecture**: Uses `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` resources instead of inline rules
- **Conflict Avoidance**: Prevents rule conflicts and perpetual differences by avoiding inline rules
- **Comprehensive Rule Support**: 
  - IPv4 and IPv6 CIDR blocks
  - Security group references
  - Prefix list IDs (AWS services and custom)
  - All protocol types including ICMP
- **Flexible Configuration**:
  - Named or prefix-based security group naming
  - Per-rule descriptions and tags
  - Custom timeouts
  - Create-before-destroy lifecycle management
- **Validation**: Built-in validation to ensure proper rule configuration
- **Production Ready**: Comprehensive examples, testing, and documentation

## Usage

### Basic Web Server Security Group

```hcl
module "web_server_sg" {
  source = "path/to/aws-security-group"

  name        = "web-server-sg"
  description = "Security group for web servers"
  vpc_id      = "vpc-12345678"

  ingress_rules = [
    {
      description = "HTTP from anywhere"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "HTTPS from anywhere"
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  egress_rules = [
    {
      description = "All outbound traffic"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "web-server-sg"
  }
}
```

### Database Security Group with Security Group References

```hcl
module "database_sg" {
  source = "path/to/aws-security-group"

  name        = "database-sg"
  description = "Security group for database servers"
  vpc_id      = "vpc-12345678"

  ingress_rules = [
    {
      description                  = "MySQL from web servers"
      ip_protocol                  = "tcp"
      from_port                    = 3306
      to_port                      = 3306
      referenced_security_group_id = module.web_server_sg.id
    }
  ]

  tags = {
    Name = "database-sg"
  }
}
```

### Security Group with Prefix Lists

```hcl
module "office_access_sg" {
  source = "path/to/aws-security-group"

  name        = "office-access-sg"
  description = "Security group for office access"
  vpc_id      = "vpc-12345678"

  ingress_rules = [
    {
      description    = "SSH from office networks"
      ip_protocol    = "tcp"
      from_port      = 22
      to_port        = 22
      prefix_list_id = "pl-12345678"
    }
  ]

  egress_rules = [
    {
      description    = "HTTPS to S3"
      ip_protocol    = "tcp"
      from_port      = 443
      to_port        = 443
      prefix_list_id = data.aws_prefix_list.s3.id
    }
  ]

  tags = {
    Name = "office-access-sg"
  }
}
```

### IPv6 and Dual-Stack Support

```hcl
module "ipv6_sg" {
  source = "path/to/aws-security-group"

  name        = "ipv6-sg"
  description = "Security group with IPv6 support"
  vpc_id      = "vpc-12345678"

  ingress_rules = [
    {
      description = "HTTP from anywhere IPv4"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "HTTP from anywhere IPv6"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_ipv6   = "::/0"
    }
  ]

  egress_rules = [
    {
      description = "All outbound IPv4"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "All outbound IPv6"
      ip_protocol = "-1"
      cidr_ipv6   = "::/0"
    }
  ]

  tags = {
    Name = "ipv6-sg"
  }
}
```

## Examples

- [Basic](examples/basic/) - Basic web server and database security groups
- [Comprehensive](examples/comprehensive/) - Multi-tier application with ALB, web, database, and cache layers
- [Prefix Lists](examples/prefix-lists/) - Using AWS service and custom prefix lists

## Rule Configuration

### Ingress and Egress Rules

Each rule in `ingress_rules` and `egress_rules` supports the following parameters:

- **description** (optional): Description of the rule
- **ip_protocol** (required): IP protocol (`tcp`, `udp`, `icmp`, `icmpv6`, or `-1` for all)
- **from_port** (conditional): Start port number (required unless `ip_protocol` is `-1`)
- **to_port** (conditional): End port number (required unless `ip_protocol` is `-1`)
- **tags** (optional): Additional tags for the rule

**Exactly one** of the following source/destination parameters must be specified:

- **cidr_ipv4**: IPv4 CIDR block (e.g., `"10.0.0.0/16"`, `"0.0.0.0/0"`)
- **cidr_ipv6**: IPv6 CIDR block (e.g., `"::/0"`, `"2001:db8::/32"`)
- **prefix_list_id**: Prefix list ID (AWS service or custom)
- **referenced_security_group_id**: Another security group ID

### Protocol Configuration

- **TCP/UDP**: Specify `from_port` and `to_port`
- **ICMP**: Use `from_port` for ICMP type, `to_port` for ICMP code
- **All Protocols**: Use `ip_protocol = "-1"` with `from_port` and `to_port` as `null`

## Best Practices

### Security Group Design

1. **Principle of Least Privilege**: Only allow necessary traffic
2. **Layer-Based Security**: Create separate security groups for each tier
3. **Security Group References**: Use security group IDs instead of CIDR blocks for internal traffic
4. **Descriptive Names**: Use clear, descriptive names and descriptions

### Rule Management

1. **Separate Rules**: Each rule is managed individually for better tracking
2. **Rule Tags**: Tag rules for better organization and cost tracking
3. **Documentation**: Always include meaningful descriptions
4. **Regular Reviews**: Periodically review and clean up unused rules

### Network Architecture

1. **Defense in Depth**: Combine with NACLs and other AWS security features
2. **Monitoring**: Enable VPC Flow Logs for traffic analysis
3. **Automation**: Use Infrastructure as Code for consistent deployments

## Testing

This module includes comprehensive tests using Terratest. To run the tests:

```bash
cd test
go test -v -timeout 30m -tags=integration
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_before_destroy"></a> [create\_before\_destroy](#input\_create\_before\_destroy) | Enable create\_before\_destroy lifecycle rule to avoid deletion issues when the security group is referenced by other resources. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Security group description. Cannot be empty string. | `string` | `"Managed by Terraform"` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | List of egress rules to create. Each rule must specify exactly one destination (cidr\_ipv4, cidr\_ipv6, prefix\_list\_id, or referenced\_security\_group\_id). | <pre>list(object({<br>    description                  = optional(string)<br>    ip_protocol                  = string<br>    from_port                    = optional(number)<br>    to_port                      = optional(number)<br>    cidr_ipv4                    = optional(string)<br>    cidr_ipv6                    = optional(string)<br>    prefix_list_id               = optional(string)<br>    referenced_security_group_id = optional(string)<br>    tags                         = optional(map(string), {})<br>  }))</pre> | `[]` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | List of ingress rules to create. Each rule must specify exactly one source (cidr\_ipv4, cidr\_ipv6, prefix\_list\_id, or referenced\_security\_group\_id). | <pre>list(object({<br>    description                  = optional(string)<br>    ip_protocol                  = string<br>    from_port                    = optional(number)<br>    to_port                      = optional(number)<br>    cidr_ipv4                    = optional(string)<br>    cidr_ipv6                    = optional(string)<br>    prefix_list_id               = optional(string)<br>    referenced_security_group_id = optional(string)<br>    tags                         = optional(map(string), {})<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the security group. If omitted, Terraform will assign a random, unique name. Cannot be used with name\_prefix. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Creates a unique name beginning with the specified prefix. Conflicts with name. | `string` | `null` | no |
| <a name="input_revoke_rules_on_delete"></a> [revoke\_rules\_on\_delete](#input\_revoke\_rules\_on\_delete) | Instruct Terraform to revoke all of the Security Group's attached ingress and egress rules before deleting the rule itself. This is normally not needed, but certain AWS services may automatically add required rules that contain cyclic dependencies. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the security group. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Configuration options for timeouts. | <pre>object({<br>    create = optional(string, "10m")<br>    delete = optional(string, "15m")<br>  })</pre> | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the security group will be created. If not specified, uses the default VPC. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the security group |
| <a name="output_description"></a> [description](#output\_description) | Description of the security group |
| <a name="output_egress_rule_ids"></a> [egress\_rule\_ids](#output\_egress\_rule\_ids) | List of IDs of the egress rules |
| <a name="output_egress_rules"></a> [egress\_rules](#output\_egress\_rules) | Map of egress rule details |
| <a name="output_id"></a> [id](#output\_id) | ID of the security group |
| <a name="output_ingress_rule_ids"></a> [ingress\_rule\_ids](#output\_ingress\_rule\_ids) | List of IDs of the ingress rules |
| <a name="output_ingress_rules"></a> [ingress\_rules](#output\_ingress\_rules) | Map of ingress rule details |
| <a name="output_name"></a> [name](#output\_name) | Name of the security group |
| <a name="output_owner_id"></a> [owner\_id](#output\_owner\_id) | Owner ID of the security group |
| <a name="output_result"></a> [result](#output\_result) | The complete security group configuration result |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID of the security group |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
