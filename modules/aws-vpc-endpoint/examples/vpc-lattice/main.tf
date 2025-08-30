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
    Name = "vpc-lattice-resource-${random_id.suffix.hex}"
  }
}

# Create subnet for the VPC endpoint
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "lattice-resource-subnet-${random_id.suffix.hex}"
  }
}

# Create VPC Lattice Service Network
resource "aws_vpclattice_service_network" "main" {
  name = "lattice-service-network-${random_id.suffix.hex}"

  tags = {
    Name = "lattice-service-network-${random_id.suffix.hex}"
  }
}

# Create VPC Lattice Service
resource "aws_vpclattice_service" "main" {
  name = "lattice-service-${random_id.suffix.hex}"

  tags = {
    Name = "lattice-service-${random_id.suffix.hex}"
  }
}

# Create VPC Lattice Target Group
resource "aws_vpclattice_target_group" "main" {
  name = "lattice-tg-${random_id.suffix.hex}"
  type = "IP"
  
  config {
    vpc_identifier = aws_vpc.main.id
    port           = 80
    protocol       = "HTTP"
  }

  tags = {
    Name = "lattice-target-group-${random_id.suffix.hex}"
  }
}

# Create VPC Lattice Resource Configuration
# Note: This is a simplified example. In practice, you would create a more complex resource configuration
# based on your specific VPC Lattice requirements
resource "aws_vpclattice_resource_configuration" "main" {
  name = "lattice-resource-config-${random_id.suffix.hex}"

  tags = {
    Name = "lattice-resource-config-${random_id.suffix.hex}"
  }
}

# VPC Lattice Resource Configuration Endpoint using our module
module "vpc_lattice_resource_endpoint" {
  source = "../../"

  vpc_id                     = aws_vpc.main.id
  resource_configuration_arn = aws_vpclattice_resource_configuration.main.arn
  vpc_endpoint_type          = "Resource"
  subnet_ids                 = [aws_subnet.main.id]

  tags = {
    Name        = "vpc-lattice-resource-endpoint-${random_id.suffix.hex}"
    Environment = "test"
    Type        = "Resource"
    Service     = "VPCLattice"
  }

  # Custom timeouts for VPC Lattice endpoints
  timeouts = {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}

# Service Network Endpoint using our module
module "vpc_lattice_service_network_endpoint" {
  source = "../../"

  vpc_id              = aws_vpc.main.id
  service_network_arn = aws_vpclattice_service_network.main.arn
  vpc_endpoint_type   = "ServiceNetwork"
  subnet_ids          = [aws_subnet.main.id]

  tags = {
    Name        = "vpc-lattice-servicenetwork-endpoint-${random_id.suffix.hex}"
    Environment = "test"
    Type        = "ServiceNetwork"
    Service     = "VPCLattice"
  }

  # Custom timeouts for VPC Lattice endpoints
  timeouts = {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}

# Outputs
output "resource_endpoint_id" {
  description = "The ID of the VPC Lattice Resource VPC endpoint"
  value       = module.vpc_lattice_resource_endpoint.id
}

output "resource_endpoint_arn" {
  description = "The ARN of the VPC Lattice Resource VPC endpoint"
  value       = module.vpc_lattice_resource_endpoint.arn
}

output "resource_endpoint_state" {
  description = "The state of the VPC Lattice Resource VPC endpoint"
  value       = module.vpc_lattice_resource_endpoint.state
}

output "service_network_endpoint_id" {
  description = "The ID of the VPC Lattice Service Network VPC endpoint"
  value       = module.vpc_lattice_service_network_endpoint.id
}

output "service_network_endpoint_arn" {
  description = "The ARN of the VPC Lattice Service Network VPC endpoint"
  value       = module.vpc_lattice_service_network_endpoint.arn
}

output "service_network_endpoint_state" {
  description = "The state of the VPC Lattice Service Network VPC endpoint"
  value       = module.vpc_lattice_service_network_endpoint.state
}

output "lattice_service_network_arn" {
  description = "The ARN of the VPC Lattice Service Network"
  value       = aws_vpclattice_service_network.main.arn
}

output "lattice_resource_configuration_arn" {
  description = "The ARN of the VPC Lattice Resource Configuration"
  value       = aws_vpclattice_resource_configuration.main.arn
}
