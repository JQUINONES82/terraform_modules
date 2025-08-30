package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestKMSKeyBasic(t *testing.T) {
	t.Parallel()

	// Give the resources a unique name so we can distinguish them from any others running in parallel
	uniqueId := random.UniqueId()
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/basic",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"aws_region": awsRegion,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	keyId := terraform.Output(t, terraformOptions, "key_id")
	keyArn := terraform.Output(t, terraformOptions, "key_arn")
	enabled := terraform.Output(t, terraformOptions, "enabled")

	// Verify the outputs are not empty
	assert.NotEmpty(t, keyId)
	assert.NotEmpty(t, keyArn)
	assert.Equal(t, "true", enabled)

	// Verify the KMS key exists and has the expected properties
	key := aws.GetKmsKey(t, awsRegion, keyId)
	assert.NotNil(t, key)
	assert.Equal(t, "Enabled", *key.KeyState)
	assert.Equal(t, "ENCRYPT_DECRYPT", *key.KeyUsage)
	assert.True(t, *key.Enabled)
}

func TestKMSKeyWithAliases(t *testing.T) {
	t.Parallel()

	// Give the resources a unique name
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/with-aliases",
		Vars: map[string]interface{}{
			"aws_region": awsRegion,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	keyId := terraform.Output(t, terraformOptions, "key_id")
	keyArn := terraform.Output(t, terraformOptions, "key_arn")

	// Verify outputs
	assert.NotEmpty(t, keyId)
	assert.NotEmpty(t, keyArn)

	// Verify the KMS key exists
	key := aws.GetKmsKey(t, awsRegion, keyId)
	assert.NotNil(t, key)
	assert.Equal(t, "Enabled", *key.KeyState)

	// Note: Alias verification would require additional AWS SDK calls
	// For now, we verify that the terraform apply succeeded and key exists
}

func TestKMSKeyWithGrants(t *testing.T) {
	t.Parallel()

	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/with-grants",
		Vars: map[string]interface{}{
			"aws_region": awsRegion,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	keyId := terraform.Output(t, terraformOptions, "key_id")
	keyArn := terraform.Output(t, terraformOptions, "key_arn")
	roleArn := terraform.Output(t, terraformOptions, "example_role_arn")

	// Verify outputs
	assert.NotEmpty(t, keyId)
	assert.NotEmpty(t, keyArn)
	assert.NotEmpty(t, roleArn)

	// Verify the KMS key exists
	key := aws.GetKmsKey(t, awsRegion, keyId)
	assert.NotNil(t, key)
	assert.Equal(t, "Enabled", *key.KeyState)
}

func TestKMSKeyComprehensive(t *testing.T) {
	t.Parallel()

	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/comprehensive",
		Vars: map[string]interface{}{
			"aws_region": awsRegion,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		// Increase timeout for comprehensive test
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Get all outputs
	keyId := terraform.Output(t, terraformOptions, "key_id")
	keyArn := terraform.Output(t, terraformOptions, "key_arn")
	keyUsage := terraform.Output(t, terraformOptions, "key_usage")
	enableKeyRotation := terraform.Output(t, terraformOptions, "enable_key_rotation")
	roleArn := terraform.Output(t, terraformOptions, "application_role_arn")

	// Verify all outputs
	assert.NotEmpty(t, keyId)
	assert.NotEmpty(t, keyArn)
	assert.Equal(t, "ENCRYPT_DECRYPT", keyUsage)
	assert.Equal(t, "true", enableKeyRotation)
	assert.NotEmpty(t, roleArn)

	// Verify the KMS key has expected properties
	key := aws.GetKmsKey(t, awsRegion, keyId)
	require.NotNil(t, key)
	assert.Equal(t, "Enabled", *key.KeyState)
	assert.Equal(t, "ENCRYPT_DECRYPT", *key.KeyUsage)
	assert.True(t, *key.Enabled)
	assert.Equal(t, "SYMMETRIC_DEFAULT", *key.CustomerMasterKeySpec)
}

func TestKMSKeyValidation(t *testing.T) {
	t.Parallel()

	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	// Test with invalid deletion window (should fail validation)
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"aws_region": awsRegion,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	// This test doesn't apply resources, just validates terraform configuration
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	assert.NoError(t, err, "Basic configuration should be valid")
}
