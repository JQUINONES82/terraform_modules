# tflint-ignore: all

# Data sources
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_caller_identity" "current" {}

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
    Name = "gateway-lb-endpoint-vpc-${random_id.suffix.hex}"
  }
}

# Create subnet for the Gateway Load Balancer
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "gateway-lb-subnet-${random_id.suffix.hex}"
  }
}

# Create subnet for the VPC endpoint
resource "aws_subnet" "endpoint" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "endpoint-subnet-${random_id.suffix.hex}"
  }
}

# Create a Gateway Load Balancer (simplified for example)
resource "aws_lb" "gateway" {
  name               = "gateway-lb-${random_id.suffix.hex}"
  load_balancer_type = "gateway"
  subnets            = [aws_subnet.main.id]

  enable_deletion_protection = false

  tags = {
    Name = "gateway-lb-${random_id.suffix.hex}"
  }
}

# Create VPC Endpoint Service for the Gateway Load Balancer
resource "aws_vpc_endpoint_service" "gateway_lb" {
  acceptance_required        = false
  allowed_principals         = [data.aws_caller_identity.current.arn]
  gateway_load_balancer_arns = [aws_lb.gateway.arn]

  tags = {
    Name = "gateway-lb-service-${random_id.suffix.hex}"
  }
}

# Gateway Load Balancer Endpoint using our module
module "gateway_load_balancer_endpoint" {
  source = "../../"

  vpc_id            = aws_vpc.main.id
  service_name      = aws_vpc_endpoint_service.gateway_lb.service_name
  vpc_endpoint_type = "GatewayLoadBalancer"
  subnet_ids        = [aws_subnet.endpoint.id]

  tags = {
    Name        = "gateway-lb-endpoint-${random_id.suffix.hex}"
    Environment = "test"
    Type        = "GatewayLoadBalancer"
  }

  # Custom timeouts for Gateway Load Balancer endpoints
  timeouts = {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# Outputs
output "gateway_lb_endpoint_id" {
  description = "The ID of the Gateway Load Balancer VPC endpoint"
  value       = module.gateway_load_balancer_endpoint.id
}

output "gateway_lb_endpoint_arn" {
  description = "The ARN of the Gateway Load Balancer VPC endpoint"
  value       = module.gateway_load_balancer_endpoint.arn
}

output "gateway_lb_endpoint_state" {
  description = "The state of the Gateway Load Balancer VPC endpoint"
  value       = module.gateway_load_balancer_endpoint.state
}

output "gateway_lb_service_name" {
  description = "The service name of the Gateway Load Balancer"
  value       = aws_vpc_endpoint_service.gateway_lb.service_name
}
