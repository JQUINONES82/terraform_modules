# tflint-ignore: all

# Data sources
data "aws_region" "current" {}
data "aws_vpc" "default" {
  default = true
}

# Random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

# Basic web server security group
module "web_server_sg" {
  source = "../../"

  name        = "web-server-sg-${random_id.suffix.hex}"
  description = "Security group for web servers"
  vpc_id      = data.aws_vpc.default.id

  # Allow HTTP and HTTPS from anywhere
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
    },
    {
      description = "SSH from VPC"
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_ipv4   = data.aws_vpc.default.cidr_block
    }
  ]

  # Allow all outbound traffic
  egress_rules = [
    {
      description = "All outbound traffic"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  tags = {
    Name        = "web-server-sg-${random_id.suffix.hex}"
    Environment = "test"
    Purpose     = "WebServer"
  }
}

# Database security group
module "database_sg" {
  source = "../../"

  name        = "database-sg-${random_id.suffix.hex}"
  description = "Security group for database servers"
  vpc_id      = data.aws_vpc.default.id

  # Allow MySQL/Aurora from web servers
  ingress_rules = [
    {
      description                  = "MySQL from web servers"
      ip_protocol                  = "tcp"
      from_port                    = 3306
      to_port                      = 3306
      referenced_security_group_id = module.web_server_sg.id
    }
  ]

  # No outbound rules - only responding to inbound connections
  egress_rules = []

  tags = {
    Name        = "database-sg-${random_id.suffix.hex}"
    Environment = "test"
    Purpose     = "Database"
  }
}

# Outputs
output "web_server_sg_id" {
  description = "ID of the web server security group"
  value       = module.web_server_sg.id
}

output "web_server_sg_arn" {
  description = "ARN of the web server security group"
  value       = module.web_server_sg.arn
}

output "database_sg_id" {
  description = "ID of the database security group"
  value       = module.database_sg.id
}

output "database_sg_arn" {
  description = "ARN of the database security group"
  value       = module.database_sg.arn
}

output "ingress_rule_count" {
  description = "Number of ingress rules created"
  value       = length(module.web_server_sg.ingress_rule_ids) + length(module.database_sg.ingress_rule_ids)
}

output "egress_rule_count" {
  description = "Number of egress rules created"
  value       = length(module.web_server_sg.egress_rule_ids) + length(module.database_sg.egress_rule_ids)
}
