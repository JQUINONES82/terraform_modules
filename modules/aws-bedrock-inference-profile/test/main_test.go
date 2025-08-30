package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBedrockInferenceProfileBasic(t *testing.T) {
	// Configure Terraform options with the path to the basic example
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"profile_name":        "test-basic-inference-profile",
			"profile_description": "Test inference profile for basic example",
			"aws_region":          "us-west-2",
		},
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Verify the inference profile was created successfully
	profileArn := terraform.Output(t, terraformOptions, "inference_profile_arn")
	profileId := terraform.Output(t, terraformOptions, "inference_profile_id")
	profileName := terraform.Output(t, terraformOptions, "inference_profile_name")
	profileStatus := terraform.Output(t, terraformOptions, "inference_profile_status")
	profileType := terraform.Output(t, terraformOptions, "inference_profile_type")
	accountId := terraform.Output(t, terraformOptions, "account_id")

	// Assert that outputs are not empty
	assert.NotEmpty(t, profileArn)
	assert.NotEmpty(t, profileId)
	assert.Equal(t, "test-basic-inference-profile", profileName)
	assert.Equal(t, "ACTIVE", profileStatus)
	assert.Equal(t, "APPLICATION", profileType)
	assert.NotEmpty(t, accountId)

	// Assert that ARN contains expected components
	assert.Contains(t, profileArn, "arn:aws:bedrock")
	assert.Contains(t, profileArn, "inference-profile")
	assert.Contains(t, profileArn, accountId)
}

func TestBedrockInferenceProfileAdvanced(t *testing.T) {
	// Configure Terraform options with the path to the advanced example
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/advanced",
		Vars: map[string]interface{}{
			"project_name":                   "test-advanced-project",
			"aws_region":                     "us-west-2",
			"enable_cross_account_profile":   false, // Disable cross-account for testing
		},
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Verify the inference profiles were created successfully
	accountId := terraform.Output(t, terraformOptions, "account_id")
	devProfileArn := terraform.Output(t, terraformOptions, "dev_profile_arn")
	stagingProfileArn := terraform.Output(t, terraformOptions, "staging_profile_arn")
	prodProfileArn := terraform.Output(t, terraformOptions, "prod_profile_arn")
	devProfileStatus := terraform.Output(t, terraformOptions, "dev_profile_status")
	stagingProfileStatus := terraform.Output(t, terraformOptions, "staging_profile_status")
	prodProfileStatus := terraform.Output(t, terraformOptions, "prod_profile_status")
	profileCount := terraform.Output(t, terraformOptions, "profile_count")

	// Assert that outputs are not empty
	assert.NotEmpty(t, accountId)
	assert.NotEmpty(t, devProfileArn)
	assert.NotEmpty(t, stagingProfileArn)
	assert.NotEmpty(t, prodProfileArn)
	assert.Equal(t, "ACTIVE", devProfileStatus)
	assert.Equal(t, "ACTIVE", stagingProfileStatus)
	assert.Equal(t, "ACTIVE", prodProfileStatus)
	assert.Equal(t, "3", profileCount) // 3 profiles when cross-account is disabled

	// Assert that all ARNs are different
	assert.NotEqual(t, devProfileArn, stagingProfileArn)
	assert.NotEqual(t, stagingProfileArn, prodProfileArn)
	assert.NotEqual(t, devProfileArn, prodProfileArn)

	// Assert that ARNs contain expected components
	assert.Contains(t, devProfileArn, "arn:aws:bedrock")
	assert.Contains(t, stagingProfileArn, "arn:aws:bedrock")
	assert.Contains(t, prodProfileArn, "arn:aws:bedrock")
	assert.Contains(t, devProfileArn, "inference-profile")
	assert.Contains(t, stagingProfileArn, "inference-profile")
	assert.Contains(t, prodProfileArn, "inference-profile")
}
