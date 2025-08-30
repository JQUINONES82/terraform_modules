# tflint-ignore: all

# Data sources
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# Random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

# Create a VPC for testing
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-endpoint-comprehensive-${random_id.suffix.hex}"
  }
}

# Create subnets in different AZs
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}-${random_id.suffix.hex}"
    Type = "Private"
  }
}

# Create a route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt-${random_id.suffix.hex}"
  }
}

# Associate route table with private subnets
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security group for interface endpoints
resource "aws_security_group" "vpc_endpoint" {
  name_prefix = "vpc-endpoint-${random_id.suffix.hex}"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoint-sg-${random_id.suffix.hex}"
  }
}

# S3 Gateway Endpoint with policy
module "s3_gateway_endpoint" {
  source = "../../"

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  # S3 access policy
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
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:PrincipalVpc" = aws_vpc.main.id
          }
        }
      }
    ]
  })

  tags = {
    Name        = "s3-gateway-endpoint-${random_id.suffix.hex}"
    Environment = "comprehensive-test"
    Type        = "Gateway"
  }
}

# EC2 Interface Endpoint
module "ec2_interface_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true

  tags = {
    Name        = "ec2-interface-endpoint-${random_id.suffix.hex}"
    Environment = "comprehensive-test"
    Type        = "Interface"
  }
}

# ECS Interface Endpoint with DNS options
module "ecs_interface_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true

  dns_options = {
    dns_record_ip_type = "ipv4"
  }

  tags = {
    Name        = "ecs-interface-endpoint-${random_id.suffix.hex}"
    Environment = "comprehensive-test"
    Type        = "Interface"
  }
}

# Interface Endpoint with specific IP addresses
module "ssm_interface_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true

  subnet_configurations = [
    {
      subnet_id = aws_subnet.private[0].id
      ipv4      = "10.0.1.10"
    },
    {
      subnet_id = aws_subnet.private[1].id
      ipv4      = "10.0.2.10"
    }
  ]

  tags = {
    Name        = "ssm-interface-endpoint-${random_id.suffix.hex}"
    Environment = "comprehensive-test"
    Type        = "Interface"
  }
}

# Lambda Interface Endpoint
module "lambda_interface_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.lambda"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
  ip_address_type     = "ipv4"

  timeouts = {
    create = "15m"
    update = "15m"
    delete = "15m"
  }

  tags = {
    Name        = "lambda-interface-endpoint-${random_id.suffix.hex}"
    Environment = "comprehensive-test"
    Type        = "Interface"
  }
}

# Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "s3_gateway_endpoint" {
  description = "S3 Gateway endpoint details"
  value = {
    id              = module.s3_gateway_endpoint.id
    arn             = module.s3_gateway_endpoint.arn
    prefix_list_id  = module.s3_gateway_endpoint.prefix_list_id
    cidr_blocks     = module.s3_gateway_endpoint.cidr_blocks
  }
}

output "ec2_interface_endpoint" {
  description = "EC2 Interface endpoint details"
  value = {
    id                    = module.ec2_interface_endpoint.id
    arn                   = module.ec2_interface_endpoint.arn
    dns_entry             = module.ec2_interface_endpoint.dns_entry
    network_interface_ids = module.ec2_interface_endpoint.network_interface_ids
  }
}

output "ecs_interface_endpoint" {
  description = "ECS Interface endpoint details"
  value = {
    id                    = module.ecs_interface_endpoint.id
    arn                   = module.ecs_interface_endpoint.arn
    dns_entry             = module.ecs_interface_endpoint.dns_entry
    network_interface_ids = module.ecs_interface_endpoint.network_interface_ids
  }
}

output "ssm_interface_endpoint" {
  description = "SSM Interface endpoint details"
  value = {
    id                    = module.ssm_interface_endpoint.id
    arn                   = module.ssm_interface_endpoint.arn
    dns_entry             = module.ssm_interface_endpoint.dns_entry
    network_interface_ids = module.ssm_interface_endpoint.network_interface_ids
  }
}

output "lambda_interface_endpoint" {
  description = "Lambda Interface endpoint details"
  value = {
    id                    = module.lambda_interface_endpoint.id
    arn                   = module.lambda_interface_endpoint.arn
    dns_entry             = module.lambda_interface_endpoint.dns_entry
    network_interface_ids = module.lambda_interface_endpoint.network_interface_ids
  }
}
