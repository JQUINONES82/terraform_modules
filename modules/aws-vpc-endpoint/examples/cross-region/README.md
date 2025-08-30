# Cross-Region VPC Endpoints Example

This example demonstrates how to create cross-region Interface VPC endpoints and dual-stack endpoints using the aws-vpc-endpoint module.

## Overview

This example creates:
- A VPC with necessary networking components
- Cross-region S3 Interface endpoint (connecting to us-east-1)
- Cross-region EC2 Interface endpoint (connecting to eu-west-1) with custom policy
- Dual-stack SSM Interface endpoint in the current region

## Cross-Region Features

This example showcases:
- **Cross-Region Connectivity**: Connect to AWS services in different regions
- **Service Region Specification**: Use the `service_region` parameter for explicit region targeting
- **Custom Policies**: Apply IAM policies to control access through endpoints
- **Dual-Stack IP Addressing**: Support for both IPv4 and IPv6
- **DNS Configuration**: Various DNS record types and configurations

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example creates Interface endpoints which may incur charges. Run `terraform destroy` when you don't need these resources.

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
- AWS Security Group for endpoint access
- Multiple AWS VPC Endpoints (Interface type) with different configurations

## Features Demonstrated

- Cross-region service connectivity
- Custom IAM policies for endpoint access control
- Dual-stack (IPv4/IPv6) IP addressing
- Different DNS record types
- Custom timeout configurations
- Private DNS enablement/disablement

## Outputs

| Name | Description |
|------|-------------|
| cross_region_s3_endpoint_id | The ID of the cross-region S3 VPC endpoint |
| cross_region_s3_endpoint_dns_entries | The DNS entries for the cross-region S3 VPC endpoint |
| cross_region_ec2_endpoint_id | The ID of the cross-region EC2 VPC endpoint |
| cross_region_ec2_endpoint_dns_entries | The DNS entries for the cross-region EC2 VPC endpoint |
| dualstack_ssm_endpoint_id | The ID of the dual-stack SSM VPC endpoint |
| dualstack_ssm_endpoint_dns_entries | The DNS entries for the dual-stack SSM VPC endpoint |
