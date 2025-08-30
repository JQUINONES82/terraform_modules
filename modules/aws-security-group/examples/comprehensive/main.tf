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
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true

  tags = {
    Name = "security-group-test-vpc-${random_id.suffix.hex}"
  }
}

# Create subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  ipv6_cidr_block   = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch                = true
  assign_ipv6_address_on_creation        = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}-${random_id.suffix.hex}"
    Type = "Public"
  }
}

# Create a prefix list for testing
resource "aws_ec2_managed_prefix_list" "office_ips" {
  name           = "office-ips-${random_id.suffix.hex}"
  address_family = "IPv4"
  max_entries    = 10

  entry {
    cidr        = "203.0.113.0/24"
    description = "Office Network"
  }

  tags = {
    Name = "office-ips-${random_id.suffix.hex}"
  }
}

# Comprehensive Application Load Balancer Security Group
module "alb_security_group" {
  source = "../../"

  name        = "alb-sg-${random_id.suffix.hex}"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress_rules = [
    {
      description = "HTTP from anywhere"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_ipv4   = "0.0.0.0/0"
      tags = {
        RuleType = "HTTP"
      }
    },
    {
      description = "HTTPS from anywhere"
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_ipv4   = "0.0.0.0/0"
      tags = {
        RuleType = "HTTPS"
      }
    },
    {
      description = "HTTP IPv6 from anywhere"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_ipv6   = "::/0"
      tags = {
        RuleType = "HTTP-IPv6"
      }
    },
    {
      description = "HTTPS IPv6 from anywhere"
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_ipv6   = "::/0"
      tags = {
        RuleType = "HTTPS-IPv6"
      }
    },
    {
      description    = "Admin access from office"
      ip_protocol    = "tcp"
      from_port      = 8080
      to_port        = 8080
      prefix_list_id = aws_ec2_managed_prefix_list.office_ips.id
      tags = {
        RuleType = "Admin"
      }
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
    Name        = "alb-sg-${random_id.suffix.hex}"
    Environment = "comprehensive-test"
    Tier        = "LoadBalancer"
  }
}

# Web Server Security Group with detailed rules
module "web_server_security_group" {
  source = "../../"

  name        = "web-sg-${random_id.suffix.hex}"
  description = "Security group for web servers behind ALB"
  vpc_id      = aws_vpc.main.id

  ingress_rules = [
    {
      description                  = "HTTP from ALB"
      ip_protocol                  = "tcp"
      from_port                    = 80
      to_port                      = 80
      referenced_security_group_id = module.alb_security_group.id
      tags = {
        Source = "ALB"
      }
    },
    {
      description                  = "HTTPS from ALB"
      ip_protocol                  = "tcp"
      from_port                    = 443
      to_port                      = 443
      referenced_security_group_id = module.alb_security_group.id
      tags = {
        Source = "ALB"
      }
    },
    {
      description    = "SSH from office networks"
      ip_protocol    = "tcp"
      from_port      = 22
      to_port        = 22
      prefix_list_id = aws_ec2_managed_prefix_list.office_ips.id
      tags = {
        Access = "Management"
      }
    },
    {
      description = "Custom app port from VPC"
      ip_protocol = "tcp"
      from_port   = 8000
      to_port     = 8099
      cidr_ipv4   = aws_vpc.main.cidr_block
      tags = {
        Purpose = "CustomApp"
      }
    }
  ]

  egress_rules = [
    {
      description = "HTTPS to internet for updates"
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "HTTP to internet for packages"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "DNS UDP"
      ip_protocol = "udp"
      from_port   = 53
      to_port     = 53
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "DNS TCP"
      ip_protocol = "tcp"
      from_port   = 53
      to_port     = 53
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  tags = {
    Name        = "web-sg-${random_id.suffix.hex}"
    Environment = "comprehensive-test"
    Tier        = "Application"
  }
}

# Database Security Group with strict access
module "database_security_group" {
  source = "../../"

  name        = "db-sg-${random_id.suffix.hex}"
  description = "Security group for database servers"
  vpc_id      = aws_vpc.main.id

  ingress_rules = [
    {
      description                  = "MySQL from web servers"
      ip_protocol                  = "tcp"
      from_port                    = 3306
      to_port                      = 3306
      referenced_security_group_id = module.web_server_security_group.id
      tags = {
        Database = "MySQL"
        Source   = "WebServers"
      }
    },
    {
      description                  = "PostgreSQL from web servers"
      ip_protocol                  = "tcp"
      from_port                    = 5432
      to_port                      = 5432
      referenced_security_group_id = module.web_server_security_group.id
      tags = {
        Database = "PostgreSQL"
        Source   = "WebServers"
      }
    },
    {
      description    = "Database admin from office"
      ip_protocol    = "tcp"
      from_port      = 3306
      to_port        = 3306
      prefix_list_id = aws_ec2_managed_prefix_list.office_ips.id
      tags = {
        Access = "Admin"
      }
    }
  ]

  # No outbound rules for database - it should only respond to connections
  egress_rules = []

  tags = {
    Name        = "db-sg-${random_id.suffix.hex}"
    Environment = "comprehensive-test"
    Tier        = "Database"
  }
}

# Cache Security Group (Redis/ElastiCache)
module "cache_security_group" {
  source = "../../"

  name        = "cache-sg-${random_id.suffix.hex}"
  description = "Security group for cache servers (Redis/ElastiCache)"
  vpc_id      = aws_vpc.main.id

  ingress_rules = [
    {
      description                  = "Redis from web servers"
      ip_protocol                  = "tcp"
      from_port                    = 6379
      to_port                      = 6379
      referenced_security_group_id = module.web_server_security_group.id
      tags = {
        Service = "Redis"
      }
    },
    {
      description                  = "Memcached from web servers"
      ip_protocol                  = "tcp"
      from_port                    = 11211
      to_port                      = 11211
      referenced_security_group_id = module.web_server_security_group.id
      tags = {
        Service = "Memcached"
      }
    }
  ]

  egress_rules = []

  tags = {
    Name        = "cache-sg-${random_id.suffix.hex}"
    Environment = "comprehensive-test"
    Tier        = "Cache"
  }
}

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "alb_security_group" {
  description = "ALB security group details"
  value = {
    id   = module.alb_security_group.id
    arn  = module.alb_security_group.arn
    name = module.alb_security_group.name
  }
}

output "web_security_group" {
  description = "Web server security group details"
  value = {
    id   = module.web_server_security_group.id
    arn  = module.web_server_security_group.arn
    name = module.web_server_security_group.name
  }
}

output "database_security_group" {
  description = "Database security group details"
  value = {
    id   = module.database_security_group.id
    arn  = module.database_security_group.arn
    name = module.database_security_group.name
  }
}

output "cache_security_group" {
  description = "Cache security group details"
  value = {
    id   = module.cache_security_group.id
    arn  = module.cache_security_group.arn
    name = module.cache_security_group.name
  }
}

output "total_ingress_rules" {
  description = "Total number of ingress rules created"
  value = (
    length(module.alb_security_group.ingress_rule_ids) +
    length(module.web_server_security_group.ingress_rule_ids) +
    length(module.database_security_group.ingress_rule_ids) +
    length(module.cache_security_group.ingress_rule_ids)
  )
}

output "total_egress_rules" {
  description = "Total number of egress rules created"
  value = (
    length(module.alb_security_group.egress_rule_ids) +
    length(module.web_server_security_group.egress_rule_ids) +
    length(module.database_security_group.egress_rule_ids) +
    length(module.cache_security_group.egress_rule_ids)
  )
}
