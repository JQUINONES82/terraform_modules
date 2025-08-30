package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBedrockGuardrailBasic(t *testing.T) {
	// Configure Terraform options with the path to the basic example
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"guardrail_name": "test-basic-guardrail",
			"aws_region":     "us-east-1",
		},
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Verify the guardrail was created successfully
	guardrailId := terraform.Output(t, terraformOptions, "guardrail_id")
	guardrailArn := terraform.Output(t, terraformOptions, "guardrail_arn")
	guardrailName := terraform.Output(t, terraformOptions, "guardrail_name")

	// Assert that outputs are not empty
	assert.NotEmpty(t, guardrailId)
	assert.NotEmpty(t, guardrailArn)
	assert.Equal(t, "test-basic-guardrail", guardrailName)
}

func TestBedrockGuardrailComprehensive(t *testing.T) {
	// Configure Terraform options with the path to the comprehensive example
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/comprehensive",
		Vars: map[string]interface{}{
			"guardrail_name": "test-comprehensive-guardrail",
			"aws_region":     "us-east-1",
		},
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Verify the guardrail was created successfully
	guardrailId := terraform.Output(t, terraformOptions, "guardrail_id")
	guardrailArn := terraform.Output(t, terraformOptions, "guardrail_arn")
	guardrailName := terraform.Output(t, terraformOptions, "guardrail_name")
	guardrailStatus := terraform.Output(t, terraformOptions, "guardrail_status")

	// Assert that outputs are not empty
	assert.NotEmpty(t, guardrailId)
	assert.NotEmpty(t, guardrailArn)
	assert.Equal(t, "test-comprehensive-guardrail", guardrailName)
	assert.NotEmpty(t, guardrailStatus)
}
