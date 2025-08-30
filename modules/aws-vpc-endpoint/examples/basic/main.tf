# tflint-ignore: all

# Create a VPC for testing
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-endpoint-test"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vpc-endpoint-test-igw"
  }
}

# Create a route table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "vpc-endpoint-test-rt"
  }
}

# Basic S3 Gateway Endpoint
module "s3_gateway_endpoint" {
  source = "../../"

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.main.id]

  tags = {
    Name        = "s3-gateway-endpoint"
    Environment = "test"
  }
}

# Basic DynamoDB Gateway Endpoint
module "dynamodb_gateway_endpoint" {
  source = "../../"

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.main.id]

  tags = {
    Name        = "dynamodb-gateway-endpoint"
    Environment = "test"
  }
}

# Data sources
data "aws_region" "current" {}

# Outputs
output "s3_endpoint_id" {
  description = "The ID of the S3 VPC endpoint"
  value       = module.s3_gateway_endpoint.id
}

output "s3_endpoint_prefix_list_id" {
  description = "The prefix list ID of the S3 endpoint"
  value       = module.s3_gateway_endpoint.prefix_list_id
}

output "dynamodb_endpoint_id" {
  description = "The ID of the DynamoDB VPC endpoint"
  value       = module.dynamodb_gateway_endpoint.id
}

output "dynamodb_endpoint_prefix_list_id" {
  description = "The prefix list ID of the DynamoDB endpoint"
  value       = module.dynamodb_gateway_endpoint.prefix_list_id
}
