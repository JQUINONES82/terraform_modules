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

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "interface-endpoint-vpc-${random_id.suffix.hex}"
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}-${random_id.suffix.hex}"
  }
}

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoint" {
  name_prefix = "vpc-endpoint-${random_id.suffix.hex}"
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
    Name = "vpc-endpoint-sg-${random_id.suffix.hex}"
  }
}

# S3 Interface Endpoint (for API calls)
module "s3_interface_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true

  # Policy to restrict access to specific buckets
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-private-bucket",
          "arn:aws:s3:::my-private-bucket/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "s3-interface-endpoint-${random_id.suffix.hex}"
    Environment = "interface-test"
    Service     = "S3"
  }
}

# RDS Interface Endpoint
module "rds_interface_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.rds"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true

  dns_options = {
    dns_record_ip_type = "ipv4"
  }

  tags = {
    Name        = "rds-interface-endpoint-${random_id.suffix.hex}"
    Environment = "interface-test"
    Service     = "RDS"
  }
}

# SQS Interface Endpoint
module "sqs_interface_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true

  tags = {
    Name        = "sqs-interface-endpoint-${random_id.suffix.hex}"
    Environment = "interface-test"
    Service     = "SQS"
  }
}

# SNS Interface Endpoint
module "sns_interface_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.sns"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true

  tags = {
    Name        = "sns-interface-endpoint-${random_id.suffix.hex}"
    Environment = "interface-test"
    Service     = "SNS"
  }
}

# CloudWatch Logs Interface Endpoint
module "logs_interface_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true

  tags = {
    Name        = "logs-interface-endpoint-${random_id.suffix.hex}"
    Environment = "interface-test"
    Service     = "CloudWatch Logs"
  }
}

# Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "endpoints" {
  description = "Details of all interface endpoints"
  value = {
    s3 = {
      id                    = module.s3_interface_endpoint.id
      arn                   = module.s3_interface_endpoint.arn
      dns_entry             = module.s3_interface_endpoint.dns_entry
      network_interface_ids = module.s3_interface_endpoint.network_interface_ids
    }
    rds = {
      id                    = module.rds_interface_endpoint.id
      arn                   = module.rds_interface_endpoint.arn
      dns_entry             = module.rds_interface_endpoint.dns_entry
      network_interface_ids = module.rds_interface_endpoint.network_interface_ids
    }
    sqs = {
      id                    = module.sqs_interface_endpoint.id
      arn                   = module.sqs_interface_endpoint.arn
      dns_entry             = module.sqs_interface_endpoint.dns_entry
      network_interface_ids = module.sqs_interface_endpoint.network_interface_ids
    }
    sns = {
      id                    = module.sns_interface_endpoint.id
      arn                   = module.sns_interface_endpoint.arn
      dns_entry             = module.sns_interface_endpoint.dns_entry
      network_interface_ids = module.sns_interface_endpoint.network_interface_ids
    }
    logs = {
      id                    = module.logs_interface_endpoint.id
      arn                   = module.logs_interface_endpoint.arn
      dns_entry             = module.logs_interface_endpoint.dns_entry
      network_interface_ids = module.logs_interface_endpoint.network_interface_ids
    }
  }
}
