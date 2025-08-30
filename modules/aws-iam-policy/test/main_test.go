package test

import (
	"encoding/json"
	"fmt"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestBasicIAMPolicy(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	policyArn := terraform.Output(t, terraformOptions, "policy_arn")
	policyName := terraform.Output(t, terraformOptions, "policy_name")
	policyId := terraform.Output(t, terraformOptions, "policy_id")

	// Verify outputs are not empty
	assert.NotEmpty(t, policyArn)
	assert.NotEmpty(t, policyName)
	assert.NotEmpty(t, policyId)

	// Verify policy name
	assert.Equal(t, "basic-s3-read-policy", policyName)

	// Verify policy exists in AWS
	sess, err := session.NewSession(&aws.Config{Region: aws.String("us-east-1")})
	require.NoError(t, err)

	iamClient := iam.New(sess)
	
	// Get policy details
	getPolicyInput := &iam.GetPolicyInput{
		PolicyArn: aws.String(policyArn),
	}
	
	policy, err := iamClient.GetPolicy(getPolicyInput)
	require.NoError(t, err)
	assert.NotNil(t, policy.Policy)
	assert.Equal(t, policyName, *policy.Policy.PolicyName)
	assert.Contains(t, *policy.Policy.Description, "Basic IAM policy")

	// Get policy version to verify document
	getPolicyVersionInput := &iam.GetPolicyVersionInput{
		PolicyArn: aws.String(policyArn),
		VersionId: policy.Policy.DefaultVersionId,
	}
	
	policyVersion, err := iamClient.GetPolicyVersion(getPolicyVersionInput)
	require.NoError(t, err)
	
	// Verify policy document contains expected permissions
	var policyDoc map[string]interface{}
	err = json.Unmarshal([]byte(*policyVersion.PolicyVersion.Document), &policyDoc)
	require.NoError(t, err)
	
	statements := policyDoc["Statement"].([]interface{})
	assert.Len(t, statements, 1)
	
	statement := statements[0].(map[string]interface{})
	assert.Equal(t, "Allow", statement["Effect"])
	
	actions := statement["Action"].([]interface{})
	assert.Contains(t, actions, "s3:GetObject")
	assert.Contains(t, actions, "s3:ListBucket")
}

func TestPolicyWithAttachments(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/with-attachments",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	policyArn := terraform.Output(t, terraformOptions, "policy_arn")
	policyName := terraform.Output(t, terraformOptions, "policy_name")
	attachedRoles := terraform.OutputList(t, terraformOptions, "attached_roles")
	attachedUsers := terraform.OutputList(t, terraformOptions, "attached_users")
	attachedGroups := terraform.OutputList(t, terraformOptions, "attached_groups")
	attachmentCount := terraform.Output(t, terraformOptions, "attachment_count")

	// Verify outputs
	assert.NotEmpty(t, policyArn)
	assert.Equal(t, "cloudwatch-logs-policy", policyName)
	assert.Len(t, attachedRoles, 1)
	assert.Len(t, attachedUsers, 1)
	assert.Len(t, attachedGroups, 1)
	assert.Equal(t, "3", attachmentCount)

	// Verify policy exists in AWS
	sess, err := session.NewSession(&aws.Config{Region: aws.String("us-east-1")})
	require.NoError(t, err)

	iamClient := iam.New(sess)
	
	// Verify role attachment
	listRolePoliciesInput := &iam.ListAttachedRolePoliciesInput{
		RoleName: aws.String("example-policy-role"),
	}
	
	rolePolicies, err := iamClient.ListAttachedRolePolicies(listRolePoliciesInput)
	require.NoError(t, err)
	assert.Len(t, rolePolicies.AttachedPolicies, 1)
	assert.Equal(t, policyArn, *rolePolicies.AttachedPolicies[0].PolicyArn)

	// Verify user attachment
	listUserPoliciesInput := &iam.ListAttachedUserPoliciesInput{
		UserName: aws.String("example-policy-user"),
	}
	
	userPolicies, err := iamClient.ListAttachedUserPolicies(listUserPoliciesInput)
	require.NoError(t, err)
	assert.Len(t, userPolicies.AttachedPolicies, 1)
	assert.Equal(t, policyArn, *userPolicies.AttachedPolicies[0].PolicyArn)

	// Verify group attachment
	listGroupPoliciesInput := &iam.ListAttachedGroupPoliciesInput{
		GroupName: aws.String("example-policy-group"),
	}
	
	groupPolicies, err := iamClient.ListAttachedGroupPolicies(listGroupPoliciesInput)
	require.NoError(t, err)
	assert.Len(t, groupPolicies.AttachedPolicies, 1)
	assert.Equal(t, policyArn, *groupPolicies.AttachedPolicies[0].PolicyArn)
}

func TestComprehensivePolicy(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/comprehensive",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	comprehensivePolicyArn := terraform.Output(t, terraformOptions, "comprehensive_policy_arn")
	comprehensivePolicyName := terraform.Output(t, terraformOptions, "comprehensive_policy_name")
	comprehensivePolicyPath := terraform.Output(t, terraformOptions, "comprehensive_policy_path")
	versionedPolicyArn := terraform.Output(t, terraformOptions, "versioned_policy_arn")

	// Verify comprehensive policy outputs
	assert.NotEmpty(t, comprehensivePolicyArn)
	assert.Equal(t, "comprehensive-policy-example", comprehensivePolicyName)
	assert.Equal(t, "/application/", comprehensivePolicyPath)
	assert.NotEmpty(t, versionedPolicyArn)

	// Verify policy exists in AWS
	sess, err := session.NewSession(&aws.Config{Region: aws.String("us-east-1")})
	require.NoError(t, err)

	iamClient := iam.New(sess)
	
	// Get comprehensive policy details
	getPolicyInput := &iam.GetPolicyInput{
		PolicyArn: aws.String(comprehensivePolicyArn),
	}
	
	policy, err := iamClient.GetPolicy(getPolicyInput)
	require.NoError(t, err)
	assert.Equal(t, "/application/", *policy.Policy.Path)
	assert.Contains(t, *policy.Policy.Description, "Comprehensive IAM policy")

	// Get policy document and verify it contains multiple services
	getPolicyVersionInput := &iam.GetPolicyVersionInput{
		PolicyArn: aws.String(comprehensivePolicyArn),
		VersionId: policy.Policy.DefaultVersionId,
	}
	
	policyVersion, err := iamClient.GetPolicyVersion(getPolicyVersionInput)
	require.NoError(t, err)
	
	policyDocument := *policyVersion.PolicyVersion.Document
	assert.Contains(t, policyDocument, "s3:")
	assert.Contains(t, policyDocument, "dynamodb:")
	assert.Contains(t, policyDocument, "secretsmanager:")
	assert.Contains(t, policyDocument, "kms:")
	assert.Contains(t, policyDocument, "cloudwatch:")
	assert.Contains(t, policyDocument, "sns:")

	// Verify versioned policy exists and has multiple versions
	getVersionedPolicyInput := &iam.GetPolicyInput{
		PolicyArn: aws.String(versionedPolicyArn),
	}
	
	versionedPolicy, err := iamClient.GetPolicy(getVersionedPolicyInput)
	require.NoError(t, err)
	
	// List policy versions
	listPolicyVersionsInput := &iam.ListPolicyVersionsInput{
		PolicyArn: aws.String(versionedPolicyArn),
	}
	
	policyVersions, err := iamClient.ListPolicyVersions(listPolicyVersionsInput)
	require.NoError(t, err)
	
	// Should have at least 3 versions (initial + 2 additional)
	assert.GreaterOrEqual(t, len(policyVersions.Versions), 3)
	
	// Find the default version
	var defaultVersion *iam.PolicyVersion
	for _, version := range policyVersions.Versions {
		if *version.IsDefaultVersion {
			defaultVersion = version
			break
		}
	}
	assert.NotNil(t, defaultVersion)
	assert.Equal(t, "v3", *defaultVersion.VersionId)
}

func TestDataSourcePolicy(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/data-source-policy",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	policyArn := terraform.Output(t, terraformOptions, "policy_arn")
	policyName := terraform.Output(t, terraformOptions, "policy_name")
	policyDocument := terraform.Output(t, terraformOptions, "policy_document")

	// Verify outputs
	assert.NotEmpty(t, policyArn)
	assert.Equal(t, "data-source-generated-policy", policyName)
	assert.NotEmpty(t, policyDocument)

	// Verify policy document is valid JSON
	var policyDoc map[string]interface{}
	err := json.Unmarshal([]byte(policyDocument), &policyDoc)
	require.NoError(t, err)

	// Verify it contains expected statements from both data sources
	statements := policyDoc["Statement"].([]interface{})
	assert.GreaterOrEqual(t, len(statements), 4) // Should have statements from both data sources

	// Verify policy exists in AWS
	sess, err := session.NewSession(&aws.Config{Region: aws.String("us-east-1")})
	require.NoError(t, err)

	iamClient := iam.New(sess)
	
	getPolicyInput := &iam.GetPolicyInput{
		PolicyArn: aws.String(policyArn),
	}
	
	policy, err := iamClient.GetPolicy(getPolicyInput)
	require.NoError(t, err)
	assert.Equal(t, policyName, *policy.Policy.PolicyName)
}

func TestPolicyValidation(t *testing.T) {
	t.Parallel()

	// Test with invalid JSON policy
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"policy": "invalid-json",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	})

	// This should fail during plan
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	assert.Error(t, err)
	assert.Contains(t, strings.ToLower(err.Error()), "json")
}

func TestPolicyNameValidation(t *testing.T) {
	t.Parallel()

	// Generate a random unique name that's too long
	longName := fmt.Sprintf("test-policy-with-very-long-name-%s-that-exceeds-128-characters-and-should-fail-validation-because-aws-has-limits", random.UniqueId())

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"policy_name": longName,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	})

	// This should fail during plan due to name length validation
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	assert.Error(t, err)
}
