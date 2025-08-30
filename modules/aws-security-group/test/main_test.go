//go:build integration

package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/aws"
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
	webServerSgID := terraform.Output(t, terraformOptions, "web_server_sg_id")
	webServerSgArn := terraform.Output(t, terraformOptions, "web_server_sg_arn")
	databaseSgID := terraform.Output(t, terraformOptions, "database_sg_id")
	databaseSgArn := terraform.Output(t, terraformOptions, "database_sg_arn")

	assert.NotEmpty(t, webServerSgID)
	assert.NotEmpty(t, webServerSgArn)
	assert.NotEmpty(t, databaseSgID)
	assert.NotEmpty(t, databaseSgArn)
	assert.Contains(t, webServerSgID, "sg-")
	assert.Contains(t, webServerSgArn, "arn:aws:ec2:")
	assert.Contains(t, databaseSgID, "sg-")
	assert.Contains(t, databaseSgArn, "arn:aws:ec2:")

	// Validate rule counts
	ingressRuleCount := terraform.Output(t, terraformOptions, "ingress_rule_count")
	egressRuleCount := terraform.Output(t, terraformOptions, "egress_rule_count")
	assert.Equal(t, "4", ingressRuleCount) // 3 for web + 1 for database
	assert.Equal(t, "1", egressRuleCount)  // 1 for web server
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

	terraform.InitAndApply(t, terraformOptions)

	// Validate the outputs
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	albSg := terraform.OutputMap(t, terraformOptions, "alb_security_group")
	webSg := terraform.OutputMap(t, terraformOptions, "web_security_group")
	dbSg := terraform.OutputMap(t, terraformOptions, "database_security_group")
	cacheSg := terraform.OutputMap(t, terraformOptions, "cache_security_group")

	assert.NotEmpty(t, vpcID)
	assert.Contains(t, vpcID, "vpc-")

	// Validate ALB security group
	assert.NotEmpty(t, albSg["id"])
	assert.NotEmpty(t, albSg["arn"])
	assert.NotEmpty(t, albSg["name"])
	assert.Contains(t, albSg["id"], "sg-")
	assert.Contains(t, albSg["arn"], "arn:aws:ec2:")

	// Validate Web security group
	assert.NotEmpty(t, webSg["id"])
	assert.NotEmpty(t, webSg["arn"])
	assert.NotEmpty(t, webSg["name"])
	assert.Contains(t, webSg["id"], "sg-")

	// Validate Database security group
	assert.NotEmpty(t, dbSg["id"])
	assert.NotEmpty(t, dbSg["arn"])
	assert.NotEmpty(t, dbSg["name"])
	assert.Contains(t, dbSg["id"], "sg-")

	// Validate Cache security group
	assert.NotEmpty(t, cacheSg["id"])
	assert.NotEmpty(t, cacheSg["arn"])
	assert.NotEmpty(t, cacheSg["name"])
	assert.Contains(t, cacheSg["id"], "sg-")

	// Validate rule counts
	totalIngressRules := terraform.Output(t, terraformOptions, "total_ingress_rules")
	totalEgressRules := terraform.Output(t, terraformOptions, "total_egress_rules")
	
	// ALB: 5 ingress, 2 egress
	// Web: 4 ingress, 4 egress  
	// DB: 3 ingress, 0 egress
	// Cache: 2 ingress, 0 egress
	assert.Equal(t, "14", totalIngressRules) // 5+4+3+2
	assert.Equal(t, "6", totalEgressRules)   // 2+4+0+0
}

func TestTerraformPrefixListExample(t *testing.T) {
	t.Parallel()

	// Pick a random AWS region to test in
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/prefix-lists",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Validate the outputs
	s3PrefixListID := terraform.Output(t, terraformOptions, "s3_prefix_list_id")
	dynamodbPrefixListID := terraform.Output(t, terraformOptions, "dynamodb_prefix_list_id")
	officeNetworksPrefixListID := terraform.Output(t, terraformOptions, "office_networks_prefix_list_id")
	partnerNetworksPrefixListID := terraform.Output(t, terraformOptions, "partner_networks_prefix_list_id")

	assert.NotEmpty(t, s3PrefixListID)
	assert.NotEmpty(t, dynamodbPrefixListID)
	assert.NotEmpty(t, officeNetworksPrefixListID)
	assert.NotEmpty(t, partnerNetworksPrefixListID)
	assert.Contains(t, s3PrefixListID, "pl-")
	assert.Contains(t, dynamodbPrefixListID, "pl-")
	assert.Contains(t, officeNetworksPrefixListID, "pl-")
	assert.Contains(t, partnerNetworksPrefixListID, "pl-")

	// Validate security groups
	s3AccessSgID := terraform.Output(t, terraformOptions, "s3_access_sg_id")
	officeAccessSgID := terraform.Output(t, terraformOptions, "office_access_sg_id")
	mixedAccessSgID := terraform.Output(t, terraformOptions, "mixed_access_sg_id")

	assert.NotEmpty(t, s3AccessSgID)
	assert.NotEmpty(t, officeAccessSgID)
	assert.NotEmpty(t, mixedAccessSgID)
	assert.Contains(t, s3AccessSgID, "sg-")
	assert.Contains(t, officeAccessSgID, "sg-")
	assert.Contains(t, mixedAccessSgID, "sg-")
}
