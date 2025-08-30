# Gateway Load Balancer Endpoint Example

This example demonstrates how to create a Gateway Load Balancer VPC endpoint using the aws-vpc-endpoint module.

## Overview

This example creates:
- A VPC with necessary networking components
- A Gateway Load Balancer 
- A VPC Endpoint Service for the Gateway Load Balancer
- A Gateway Load Balancer VPC endpoint

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (Gateway Load Balancer, for example). Run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Resources

This example creates the following resources:
- AWS VPC with DNS support
- AWS Subnets for Gateway Load Balancer and VPC endpoint
- AWS Gateway Load Balancer
- AWS VPC Endpoint Service
- AWS VPC Endpoint (Gateway Load Balancer type)

## Outputs

| Name | Description |
|------|-------------|
| gateway_lb_endpoint_id | The ID of the Gateway Load Balancer VPC endpoint |
| gateway_lb_endpoint_arn | The ARN of the Gateway Load Balancer VPC endpoint |
| gateway_lb_endpoint_state | The state of the Gateway Load Balancer VPC endpoint |
| gateway_lb_service_name | The service name of the Gateway Load Balancer |
