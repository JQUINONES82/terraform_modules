# VPC Lattice Endpoints Example

This example demonstrates how to create VPC Lattice Resource and ServiceNetwork VPC endpoints using the aws-vpc-endpoint module.

## Overview

This example creates:
- A VPC with necessary networking components
- VPC Lattice Service Network
- VPC Lattice Service and Target Group
- VPC Lattice Resource Configuration
- VPC Lattice Resource endpoint
- VPC Lattice ServiceNetwork endpoint

## About VPC Lattice

Amazon VPC Lattice is an application networking service that consistently connects, monitors, and secures communications between your services, helping to improve productivity so that your developers can focus on building features that matter to your business.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (VPC Lattice services, for example). Run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Resources

This example creates the following resources:
- AWS VPC with DNS support
- AWS Subnet for VPC endpoints
- AWS VPC Lattice Service Network
- AWS VPC Lattice Service and Target Group
- AWS VPC Lattice Resource Configuration
- AWS VPC Endpoints (Resource and ServiceNetwork types)

## Outputs

| Name | Description |
|------|-------------|
| resource_endpoint_id | The ID of the VPC Lattice Resource VPC endpoint |
| resource_endpoint_arn | The ARN of the VPC Lattice Resource VPC endpoint |
| resource_endpoint_state | The state of the VPC Lattice Resource VPC endpoint |
| service_network_endpoint_id | The ID of the VPC Lattice Service Network VPC endpoint |
| service_network_endpoint_arn | The ARN of the VPC Lattice Service Network VPC endpoint |
| service_network_endpoint_state | The state of the VPC Lattice Service Network VPC endpoint |
| lattice_service_network_arn | The ARN of the VPC Lattice Service Network |
| lattice_resource_configuration_arn | The ARN of the VPC Lattice Resource Configuration |
