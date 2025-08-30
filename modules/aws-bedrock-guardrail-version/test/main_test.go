package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBedrockGuardrailVersionBasic(t *testing.T) {
	// Configure Terraform options with the path to the basic example
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"guardrail_name":       "test-basic-guardrail",
			"version_description":  "Test version for basic example",
			"aws_region":          "us-east-1",
			"skip_destroy":        false,
		},
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Verify the guardrail version was created successfully
	guardrailArn := terraform.Output(t, terraformOptions, "guardrail_arn")
	version := terraform.Output(t, terraformOptions, "version")
	versionDescription := terraform.Output(t, terraformOptions, "version_description")
	baseGuardrailId := terraform.Output(t, terraformOptions, "base_guardrail_id")

	// Assert that outputs are not empty
	assert.NotEmpty(t, guardrailArn)
	assert.NotEmpty(t, version)
	assert.Equal(t, "Test version for basic example", versionDescription)
	assert.NotEmpty(t, baseGuardrailId)
}

func TestBedrockGuardrailVersionAdvanced(t *testing.T) {
	// Configure Terraform options with the path to the advanced example
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/advanced",
		Vars: map[string]interface{}{
			"guardrail_name":              "test-advanced-guardrail",
			"dev_version_description":     "Test dev version",
			"staging_version_description": "Test staging version",
			"prod_version_description":    "Test prod version",
			"aws_region":                 "us-east-1",
		},
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Verify the guardrail versions were created successfully
	baseGuardrailArn := terraform.Output(t, terraformOptions, "base_guardrail_arn")
	baseGuardrailId := terraform.Output(t, terraformOptions, "base_guardrail_id")
	devVersion := terraform.Output(t, terraformOptions, "dev_version")
	stagingVersion := terraform.Output(t, terraformOptions, "staging_version")
	prodVersion := terraform.Output(t, terraformOptions, "prod_version")

	// Assert that outputs are not empty
	assert.NotEmpty(t, baseGuardrailArn)
	assert.NotEmpty(t, baseGuardrailId)
	assert.NotEmpty(t, devVersion)
	assert.NotEmpty(t, stagingVersion)
	assert.NotEmpty(t, prodVersion)

	// Assert that all versions are different
	assert.NotEqual(t, devVersion, stagingVersion)
	assert.NotEqual(t, stagingVersion, prodVersion)
	assert.NotEqual(t, devVersion, prodVersion)
}
