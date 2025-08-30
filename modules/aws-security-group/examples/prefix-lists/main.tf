# tflint-ignore: all

# Data sources
data "aws_region" "current" {}
data "aws_vpc" "default" {
  default = true
}

# Get S3 prefix list
data "aws_prefix_list" "s3" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.${data.aws_region.current.name}.s3"]
  }
}

# Get DynamoDB prefix list
data "aws_prefix_list" "dynamodb" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.${data.aws_region.current.name}.dynamodb"]
  }
}

# Random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

# Create custom prefix lists
resource "aws_ec2_managed_prefix_list" "office_networks" {
  name           = "office-networks-${random_id.suffix.hex}"
  address_family = "IPv4"
  max_entries    = 10

  entry {
    cidr        = "203.0.113.0/24"
    description = "Main Office"
  }

  entry {
    cidr        = "198.51.100.0/24"
    description = "Branch Office"
  }

  tags = {
    Name        = "office-networks-${random_id.suffix.hex}"
    Environment = "test"
  }
}

resource "aws_ec2_managed_prefix_list" "partner_networks" {
  name           = "partner-networks-${random_id.suffix.hex}"
  address_family = "IPv4"
  max_entries    = 5

  entry {
    cidr        = "192.0.2.0/24"
    description = "Partner A"
  }

  tags = {
    Name        = "partner-networks-${random_id.suffix.hex}"
    Environment = "test"
  }
}

# Security group using AWS service prefix lists
module "s3_access_sg" {
  source = "../../"

  name        = "s3-access-sg-${random_id.suffix.hex}"
  description = "Security group for resources accessing S3"
  vpc_id      = data.aws_vpc.default.id

  egress_rules = [
    {
      description    = "HTTPS to S3"
      ip_protocol    = "tcp"
      from_port      = 443
      to_port        = 443
      prefix_list_id = data.aws_prefix_list.s3.id
      tags = {
        Service = "S3"
      }
    },
    {
      description    = "HTTPS to DynamoDB"
      ip_protocol    = "tcp"
      from_port      = 443
      to_port        = 443
      prefix_list_id = data.aws_prefix_list.dynamodb.id
      tags = {
        Service = "DynamoDB"
      }
    }
  ]

  tags = {
    Name        = "s3-access-sg-${random_id.suffix.hex}"
    Environment = "test"
    Purpose     = "S3Access"
  }
}

# Security group using custom prefix lists
module "office_access_sg" {
  source = "../../"

  name        = "office-access-sg-${random_id.suffix.hex}"
  description = "Security group for resources accessible from office networks"
  vpc_id      = data.aws_vpc.default.id

  ingress_rules = [
    {
      description    = "SSH from office networks"
      ip_protocol    = "tcp"
      from_port      = 22
      to_port        = 22
      prefix_list_id = aws_ec2_managed_prefix_list.office_networks.id
      tags = {
        Access = "SSH"
        Source = "Office"
      }
    },
    {
      description    = "RDP from office networks"
      ip_protocol    = "tcp"
      from_port      = 3389
      to_port        = 3389
      prefix_list_id = aws_ec2_managed_prefix_list.office_networks.id
      tags = {
        Access = "RDP"
        Source = "Office"
      }
    },
    {
      description    = "HTTPS from partner networks"
      ip_protocol    = "tcp"
      from_port      = 443
      to_port        = 443
      prefix_list_id = aws_ec2_managed_prefix_list.partner_networks.id
      tags = {
        Access = "HTTPS"
        Source = "Partner"
      }
    }
  ]

  egress_rules = [
    {
      description = "All outbound"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  tags = {
    Name        = "office-access-sg-${random_id.suffix.hex}"
    Environment = "test"
    Purpose     = "OfficeAccess"
  }
}

# Security group demonstrating mixed prefix lists and CIDR blocks
module "mixed_access_sg" {
  source = "../../"

  name        = "mixed-access-sg-${random_id.suffix.hex}"
  description = "Security group with mixed access patterns"
  vpc_id      = data.aws_vpc.default.id

  ingress_rules = [
    {
      description = "HTTP from anywhere"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_ipv4   = "0.0.0.0/0"
      tags = {
        Type = "Public"
      }
    },
    {
      description    = "Admin from office"
      ip_protocol    = "tcp"
      from_port      = 8080
      to_port        = 8080
      prefix_list_id = aws_ec2_managed_prefix_list.office_networks.id
      tags = {
        Type = "Admin"
      }
    },
    {
      description = "Monitoring from specific IP"
      ip_protocol = "tcp"
      from_port   = 9090
      to_port     = 9090
      cidr_ipv4   = "203.0.113.100/32"
      tags = {
        Type = "Monitoring"
      }
    }
  ]

  egress_rules = [
    {
      description    = "AWS services"
      ip_protocol    = "tcp"
      from_port      = 443
      to_port        = 443
      prefix_list_id = data.aws_prefix_list.s3.id
    },
    {
      description = "Internet updates"
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  tags = {
    Name        = "mixed-access-sg-${random_id.suffix.hex}"
    Environment = "test"
    Purpose     = "MixedAccess"
  }
}

# Outputs
output "s3_prefix_list_id" {
  description = "ID of the S3 prefix list"
  value       = data.aws_prefix_list.s3.id
}

output "dynamodb_prefix_list_id" {
  description = "ID of the DynamoDB prefix list"
  value       = data.aws_prefix_list.dynamodb.id
}

output "office_networks_prefix_list_id" {
  description = "ID of the custom office networks prefix list"
  value       = aws_ec2_managed_prefix_list.office_networks.id
}

output "partner_networks_prefix_list_id" {
  description = "ID of the custom partner networks prefix list"
  value       = aws_ec2_managed_prefix_list.partner_networks.id
}

output "s3_access_sg_id" {
  description = "ID of the S3 access security group"
  value       = module.s3_access_sg.id
}

output "office_access_sg_id" {
  description = "ID of the office access security group"
  value       = module.office_access_sg.id
}

output "mixed_access_sg_id" {
  description = "ID of the mixed access security group"
  value       = module.mixed_access_sg.id
}
