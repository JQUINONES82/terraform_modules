# aws-vpc-endpoint

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

This module creates AWS VPC Endpoints with support for all endpoint types including Gateway, Interface, GatewayLoadBalancer, Resource, and ServiceNetwork endpoints with comprehensive configuration options.

## Features

- **Multiple Endpoint Types**: Support for Gateway, Interface, GatewayLoadBalancer, Resource, and ServiceNetwork endpoints
- **Comprehensive Configuration**: 
  - DNS options and private DNS configuration
  - Security group and subnet configuration
  - Route table association for Gateway endpoints
  - Custom IP address assignment
  - Policy attachment for access control
- **Advanced Features**:
  - Subnet-specific IP address configuration
  - DNS record type customization
  - Cross-region service connections
  - Timeout configuration
- **Validation**: Built-in validation to ensure proper configuration based on endpoint type
- **Flexibility**: Support for AWS services, AWS Marketplace services, and VPC Lattice services

## Usage

### Basic Gateway Endpoint

```hcl
module "s3_gateway_endpoint" {
  source = "path/to/aws-vpc-endpoint"

  vpc_id            = "vpc-12345678"
  service_name      = "com.amazonaws.us-west-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = ["rtb-12345678"]

  tags = {
    Name = "s3-gateway-endpoint"
  }
}
```

### Interface Endpoint with DNS

```hcl
module "ec2_interface_endpoint" {
  source = "path/to/aws-vpc-endpoint"

  vpc_id              = "vpc-12345678"
  service_name        = "com.amazonaws.us-west-2.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = ["subnet-12345678", "subnet-87654321"]
  security_group_ids  = ["sg-12345678"]
  private_dns_enabled = true

  dns_options = {
    dns_record_ip_type = "ipv4"
  }

  tags = {
    Name = "ec2-interface-endpoint"
  }
}
```

### Interface Endpoint with Custom IP Addresses

```hcl
module "ssm_interface_endpoint" {
  source = "path/to/aws-vpc-endpoint"

  vpc_id              = "vpc-12345678"
  service_name        = "com.amazonaws.us-west-2.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = ["subnet-12345678", "subnet-87654321"]
  security_group_ids  = ["sg-12345678"]
  private_dns_enabled = true

  subnet_configurations = [
    {
      subnet_id = "subnet-12345678"
      ipv4      = "10.0.1.10"
    },
    {
      subnet_id = "subnet-87654321"
      ipv4      = "10.0.2.10"
    }
  ]

  tags = {
    Name = "ssm-interface-endpoint"
  }
}
```

### Gateway Endpoint with Policy

```hcl
module "s3_gateway_endpoint_with_policy" {
  source = "path/to/aws-vpc-endpoint"

  vpc_id            = "vpc-12345678"
  service_name      = "com.amazonaws.us-west-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = ["rtb-12345678"]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::my-bucket/*"
        Condition = {
          StringEquals = {
            "aws:PrincipalVpc" = "vpc-12345678"
          }
        }
      }
    ]
  })

  tags = {
    Name = "s3-gateway-endpoint-with-policy"
  }
}
```

### VPC Lattice Service Network Endpoint

```hcl
module "lattice_service_network_endpoint" {
  source = "path/to/aws-vpc-endpoint"

  vpc_id               = "vpc-12345678"
  service_network_arn  = "arn:aws:vpc-lattice:us-west-2:123456789012:servicenetwork/sn-12345678"
  vpc_endpoint_type    = "ServiceNetwork"
  subnet_ids           = ["subnet-12345678"]

  tags = {
    Name = "lattice-service-network-endpoint"
  }
}
```

### Gateway Load Balancer Endpoint

```hcl
module "gateway_load_balancer_endpoint" {
  source = "path/to/aws-vpc-endpoint"

  vpc_id            = "vpc-12345678"
  service_name      = "com.amazonaws.vpce-svc-12345678"
  vpc_endpoint_type = "GatewayLoadBalancer"
  subnet_ids        = ["subnet-12345678"]

  tags = {
    Name = "gateway-lb-endpoint"
  }
}
```

### Cross-Region Interface Endpoint

```hcl
module "cross_region_s3_endpoint" {
  source = "path/to/aws-vpc-endpoint"

  vpc_id              = "vpc-12345678"
  service_name        = "com.amazonaws.us-east-1.s3"
  service_region      = "us-east-1"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = ["subnet-12345678"]
  security_group_ids  = ["sg-12345678"]
  private_dns_enabled = true

  dns_options = {
    dns_record_ip_type = "dualstack"
  }

  tags = {
    Name = "cross-region-s3-endpoint"
  }
}
```

## Examples

- [Basic](examples/basic/) - Basic Gateway endpoints for S3 and DynamoDB
- [Comprehensive](examples/comprehensive/) - Full-featured examples with Gateway and Interface endpoints
- [Interface Endpoint](examples/interface-endpoint/) - Multiple Interface endpoints with various configurations
- [Gateway Load Balancer](examples/gateway-load-balancer/) - Gateway Load Balancer endpoint configuration
- [VPC Lattice](examples/vpc-lattice/) - VPC Lattice Resource and ServiceNetwork endpoints
- [Cross-Region](examples/cross-region/) - Cross-region endpoints and dual-stack configurations

## Supported Services

### Gateway Endpoints
- S3 (`com.amazonaws.<region>.s3`)
- DynamoDB (`com.amazonaws.<region>.dynamodb`)

### Interface Endpoints
- EC2 (`com.amazonaws.<region>.ec2`)
- ECS (`com.amazonaws.<region>.ecs`)
- Lambda (`com.amazonaws.<region>.lambda`)
- RDS (`com.amazonaws.<region>.rds`)
- SQS (`com.amazonaws.<region>.sqs`)
- SNS (`com.amazonaws.<region>.sns`)
- SSM (`com.amazonaws.<region>.ssm`)
- CloudWatch Logs (`com.amazonaws.<region>.logs`)
- KMS (`com.amazonaws.<region>.kms`)
- Secrets Manager (`com.amazonaws.<region>.secretsmanager`)
- And many more AWS services...

### Gateway Load Balancer Endpoints
- Custom VPC Endpoint Services backed by Gateway Load Balancers
- Third-party security appliances
- Network inspection services

### VPC Lattice Endpoints
- Resource Configuration endpoints
- Service Network endpoints

## Testing

This module includes comprehensive tests using Terratest. To run the tests:

```bash
cd test
go test -v -timeout 30m -tags=integration
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which the endpoint will be used. | `string` | n/a | yes |
| <a name="input_auto_accept"></a> [auto\_accept](#input\_auto\_accept) | Accept the VPC endpoint (the VPC endpoint and service need to be in the same AWS account). | `bool` | `null` | no |
| <a name="input_dns_options"></a> [dns\_options](#input\_dns\_options) | The DNS options for the endpoint. | <pre>object({<br>    dns_record_ip_type                             = optional(string)<br>    private_dns_only_for_inbound_resolver_endpoint = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | The IP address type for the endpoint. Valid values are ipv4, dualstack, and ipv6. | `string` | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A policy to attach to the endpoint that controls access to the service. This is a JSON formatted string. Defaults to full access. All Gateway and some Interface endpoints support policies. | `string` | `null` | no |
| <a name="input_private_dns_enabled"></a> [private\_dns\_enabled](#input\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC. Applicable for endpoints of type Interface. Most users will want this enabled to allow services within the VPC to automatically use the endpoint. | `bool` | `null` | no |
| <a name="input_resource_configuration_arn"></a> [resource\_configuration\_arn](#input\_resource\_configuration\_arn) | The ARN of a Resource Configuration to connect this VPC Endpoint to. Exactly one of resource\_configuration\_arn, service\_name or service\_network\_arn is required. | `string` | `null` | no |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | One or more route table IDs. Applicable for endpoints of type Gateway. | `list(string)` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface. Applicable for endpoints of type Interface. If no security groups are specified, the VPC's default security group is associated with the endpoint. | `list(string)` | `null` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The service name. For AWS services the service name is usually in the form com.amazonaws.<region>.<service> (the SageMaker AI Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook). Exactly one of resource\_configuration\_arn, service\_name or service\_network\_arn is required. | `string` | `null` | no |
| <a name="input_service_network_arn"></a> [service\_network\_arn](#input\_service\_network\_arn) | The ARN of a Service Network to connect this VPC Endpoint to. Exactly one of resource\_configuration\_arn, service\_name or service\_network\_arn is required. | `string` | `null` | no |
| <a name="input_service_region"></a> [service\_region](#input\_service\_region) | The AWS region of the VPC Endpoint Service. If specified, the VPC endpoint will connect to the service in the provided region. Applicable for endpoints of type Interface. | `string` | `null` | no |
| <a name="input_subnet_configurations"></a> [subnet\_configurations](#input\_subnet\_configurations) | Subnet configuration for the endpoint, used to select specific IPv4 and/or IPv6 addresses to the endpoint. | <pre>list(object({<br>    ipv4      = optional(string)<br>    ipv6      = optional(string)<br>    subnet_id = string<br>  }))</pre> | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for the endpoint. Applicable for endpoints of type GatewayLoadBalancer and Interface. Interface type endpoints cannot function without being assigned to a subnet. | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Configuration options for timeouts. | <pre>object({<br>    create = optional(string, "10m")<br>    update = optional(string, "10m")<br>    delete = optional(string, "10m")<br>  })</pre> | `null` | no |
| <a name="input_vpc_endpoint_type"></a> [vpc\_endpoint\_type](#input\_vpc\_endpoint\_type) | The VPC endpoint type. Valid values are Gateway, GatewayLoadBalancer, Interface, Resource, or ServiceNetwork. | `string` | `"Gateway"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the VPC endpoint |
| <a name="output_cidr_blocks"></a> [cidr\_blocks](#output\_cidr\_blocks) | The list of CIDR blocks for the exposed AWS service. Applicable for endpoints of type Gateway |
| <a name="output_dns_entry"></a> [dns\_entry](#output\_dns\_entry) | The DNS entries for the VPC Endpoint. Applicable for endpoints of type Interface |
| <a name="output_id"></a> [id](#output\_id) | The ID of the VPC endpoint |
| <a name="output_network_interface_ids"></a> [network\_interface\_ids](#output\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint. Applicable for endpoints of type Interface |
| <a name="output_owner_id"></a> [owner\_id](#output\_owner\_id) | The ID of the AWS account that owns the VPC endpoint |
| <a name="output_prefix_list_id"></a> [prefix\_list\_id](#output\_prefix\_list\_id) | The prefix list ID of the exposed AWS service. Applicable for endpoints of type Gateway |
| <a name="output_requester_managed"></a> [requester\_managed](#output\_requester\_managed) | Whether or not the VPC Endpoint is being managed by its service |
| <a name="output_result"></a> [result](#output\_result) | The result of the module. |
| <a name="output_state"></a> [state](#output\_state) | The state of the VPC endpoint |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
