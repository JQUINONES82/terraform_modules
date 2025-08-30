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
    Name = "cross-region-endpoint-vpc-${random_id.suffix.hex}"
  }
}

# Create subnet for the VPC endpoint
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "cross-region-endpoint-subnet-${random_id.suffix.hex}"
  }
}

# Security group for interface endpoints
resource "aws_security_group" "vpc_endpoint" {
  name_prefix = "cross-region-endpoint-${random_id.suffix.hex}"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from VPC"
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
    Name = "cross-region-endpoint-sg-${random_id.suffix.hex}"
  }
}

# Cross-region S3 Interface Endpoint
# This demonstrates connecting to S3 in a different region
module "cross_region_s3_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.us-east-1.s3"  # Different region
  service_region      = "us-east-1"                   # Explicitly specify the region
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.main.id]
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true

  # DNS options for cross-region endpoint
  dns_options = {
    dns_record_ip_type = "ipv4"
  }

  tags = {
    Name        = "cross-region-s3-endpoint-${random_id.suffix.hex}"
    Environment = "test"
    Type        = "CrossRegion"
    Service     = "S3"
    Region      = "us-east-1"
  }
}

# Cross-region EC2 Interface Endpoint with custom policy
module "cross_region_ec2_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-west-1.ec2"  # Europe region
  service_region      = "eu-west-1"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.main.id]
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = false  # Disable for cross-region

  # Custom policy for EC2 endpoint
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeSnapshots"
        ]
        Resource = "*"
      }
    ]
  })

  # DNS options
  dns_options = {
    dns_record_ip_type = "dualstack"
  }

  tags = {
    Name        = "cross-region-ec2-endpoint-${random_id.suffix.hex}"
    Environment = "test"
    Type        = "CrossRegion"
    Service     = "EC2"
    Region      = "eu-west-1"
  }

  # Extended timeouts for cross-region endpoints
  timeouts = {
    create = "20m"
    update = "15m"
    delete = "15m"
  }
}

# Interface Endpoint with dual-stack IP addressing
module "dualstack_ssm_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.main.id]
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
  ip_address_type     = "dualstack"

  # DNS options for dual-stack
  dns_options = {
    dns_record_ip_type = "dualstack"
  }

  tags = {
    Name        = "dualstack-ssm-endpoint-${random_id.suffix.hex}"
    Environment = "test"
    Type        = "DualStack"
    Service     = "SSM"
  }
}

# Outputs
output "cross_region_s3_endpoint_id" {
  description = "The ID of the cross-region S3 VPC endpoint"
  value       = module.cross_region_s3_endpoint.id
}

output "cross_region_s3_endpoint_dns_entries" {
  description = "The DNS entries for the cross-region S3 VPC endpoint"
  value       = module.cross_region_s3_endpoint.dns_entry
}

output "cross_region_ec2_endpoint_id" {
  description = "The ID of the cross-region EC2 VPC endpoint"
  value       = module.cross_region_ec2_endpoint.id
}

output "cross_region_ec2_endpoint_dns_entries" {
  description = "The DNS entries for the cross-region EC2 VPC endpoint"
  value       = module.cross_region_ec2_endpoint.dns_entry
}

output "dualstack_ssm_endpoint_id" {
  description = "The ID of the dual-stack SSM VPC endpoint"
  value       = module.dualstack_ssm_endpoint.id
}

output "dualstack_ssm_endpoint_dns_entries" {
  description = "The DNS entries for the dual-stack SSM VPC endpoint"
  value       = module.dualstack_ssm_endpoint.dns_entry
}
