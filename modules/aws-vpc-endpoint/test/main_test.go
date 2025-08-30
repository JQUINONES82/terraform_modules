//go:build integration

package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformBasicExample(t *testing.T) {
	t.Parallel()

	// Pick a random AWS region to test in
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Validate the outputs
	s3EndpointID := terraform.Output(t, terraformOptions, "s3_endpoint_id")
	s3PrefixListID := terraform.Output(t, terraformOptions, "s3_endpoint_prefix_list_id")
	dynamodbEndpointID := terraform.Output(t, terraformOptions, "dynamodb_endpoint_id")
	dynamodbPrefixListID := terraform.Output(t, terraformOptions, "dynamodb_endpoint_prefix_list_id")

	assert.NotEmpty(t, s3EndpointID)
	assert.NotEmpty(t, s3PrefixListID)
	assert.NotEmpty(t, dynamodbEndpointID)
	assert.NotEmpty(t, dynamodbPrefixListID)
	assert.Contains(t, s3EndpointID, "vpce-")
	assert.Contains(t, dynamodbEndpointID, "vpce-")
}

func TestTerraformComprehensiveExample(t *testing.T) {
	t.Parallel()

	// Pick a random AWS region to test in
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/comprehensive",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAnd_apply(t, terraformOptions)

	// Validate the outputs
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	s3Gateway := terraform.OutputMap(t, terraformOptions, "s3_gateway_endpoint")
	ec2Interface := terraform.OutputMap(t, terraformOptions, "ec2_interface_endpoint")
	ecsInterface := terraform.OutputMap(t, terraformOptions, "ecs_interface_endpoint")
	ssmInterface := terraform.OutputMap(t, terraformOptions, "ssm_interface_endpoint")
	lambdaInterface := terraform.OutputMap(t, terraformOptions, "lambda_interface_endpoint")

	assert.NotEmpty(t, vpcID)
	assert.Contains(t, vpcID, "vpc-")

	// Validate S3 Gateway endpoint
	assert.NotEmpty(t, s3Gateway["id"])
	assert.NotEmpty(t, s3Gateway["arn"])
	assert.NotEmpty(t, s3Gateway["prefix_list_id"])
	assert.Contains(t, s3Gateway["id"], "vpce-")
	assert.Contains(t, s3Gateway["arn"], "arn:aws:vpc:")

	// Validate EC2 Interface endpoint
	assert.NotEmpty(t, ec2Interface["id"])
	assert.NotEmpty(t, ec2Interface["arn"])
	assert.Contains(t, ec2Interface["id"], "vpce-")
	assert.Contains(t, ec2Interface["arn"], "arn:aws:vpc:")

	// Validate ECS Interface endpoint
	assert.NotEmpty(t, ecsInterface["id"])
	assert.NotEmpty(t, ecsInterface["arn"])
	assert.Contains(t, ecsInterface["id"], "vpce-")

	// Validate SSM Interface endpoint
	assert.NotEmpty(t, ssmInterface["id"])
	assert.NotEmpty(t, ssmInterface["arn"])
	assert.Contains(t, ssmInterface["id"], "vpce-")

	// Validate Lambda Interface endpoint
	assert.NotEmpty(t, lambdaInterface["id"])
	assert.NotEmpty(t, lambdaInterface["arn"])
	assert.Contains(t, lambdaInterface["id"], "vpce-")
}

func TestTerraformInterfaceEndpointExample(t *testing.T) {
	t.Parallel()

	// Pick a random AWS region to test in
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/interface-endpoint",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Validate the outputs
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	endpoints := terraform.OutputMap(t, terraformOptions, "endpoints")

	assert.NotEmpty(t, vpcID)
	assert.Contains(t, vpcID, "vpc-")

	// Validate that we have all expected endpoints
	services := []string{"s3", "rds", "sqs", "sns", "logs"}
	for _, service := range services {
		serviceEndpoint := endpoints[service].(map[string]interface{})
		assert.NotEmpty(t, serviceEndpoint["id"])
		assert.NotEmpty(t, serviceEndpoint["arn"])
		assert.Contains(t, serviceEndpoint["id"], "vpce-")
		assert.Contains(t, serviceEndpoint["arn"], "arn:aws:vpc:")
	}
}

func TestTerraformGatewayLoadBalancerExample(t *testing.T) {
	t.Parallel()

	// Pick a random AWS region to test in
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/gateway-load-balancer",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Validate the outputs
	endpointID := terraform.Output(t, terraformOptions, "gateway_lb_endpoint_id")
	endpointArn := terraform.Output(t, terraformOptions, "gateway_lb_endpoint_arn")
	endpointState := terraform.Output(t, terraformOptions, "gateway_lb_endpoint_state")

	assert.NotEmpty(t, endpointID)
	assert.NotEmpty(t, endpointArn)
	assert.NotEmpty(t, endpointState)
	assert.Contains(t, endpointID, "vpce-")
	assert.Contains(t, endpointArn, "arn:aws:vpc:")
	assert.Contains(t, []string{"available", "pending"}, endpointState)
}

func TestTerraformCrossRegionExample(t *testing.T) {
	t.Parallel()

	// Pick a random AWS region to test in
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/cross-region",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Validate the outputs
	s3EndpointID := terraform.Output(t, terraformOptions, "cross_region_s3_endpoint_id")
	ec2EndpointID := terraform.Output(t, terraformOptions, "cross_region_ec2_endpoint_id")
	ssmEndpointID := terraform.Output(t, terraformOptions, "dualstack_ssm_endpoint_id")

	assert.NotEmpty(t, s3EndpointID)
	assert.NotEmpty(t, ec2EndpointID)
	assert.NotEmpty(t, ssmEndpointID)
	assert.Contains(t, s3EndpointID, "vpce-")
	assert.Contains(t, ec2EndpointID, "vpce-")
	assert.Contains(t, ssmEndpointID, "vpce-")
}

// Note: VPC Lattice example is commented out as it requires additional setup
// and may not be available in all regions
/*
func TestTerraformVPCLatticeExample(t *testing.T) {
	t.Parallel()

	// Pick a random AWS region that supports VPC Lattice
	awsRegion := aws.GetRandomStableRegion(t, []string{"us-east-1", "us-west-2", "eu-west-1"}, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/vpc-lattice",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Validate the outputs
	resourceEndpointID := terraform.Output(t, terraformOptions, "resource_endpoint_id")
	serviceNetworkEndpointID := terraform.Output(t, terraformOptions, "service_network_endpoint_id")

	assert.NotEmpty(t, resourceEndpointID)
	assert.NotEmpty(t, serviceNetworkEndpointID)
	assert.Contains(t, resourceEndpointID, "vpce-")
	assert.Contains(t, serviceNetworkEndpointID, "vpce-")
}
*/
