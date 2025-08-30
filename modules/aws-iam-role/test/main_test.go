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

func TestBasicIAMRole(t *testing.T) {
	t.Parallel()

	// Generate a random name for the role
	roleName := fmt.Sprintf("test-basic-role-%s", random.UniqueId())

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"role_name": roleName,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	roleArn := terraform.Output(t, terraformOptions, "role_arn")
	actualRoleName := terraform.Output(t, terraformOptions, "role_name")
	instanceProfileArn := terraform.Output(t, terraformOptions, "instance_profile_arn")

	// Verify outputs are not empty
	assert.NotEmpty(t, roleArn)
	assert.NotEmpty(t, actualRoleName)
	assert.NotEmpty(t, instanceProfileArn)

	// Verify role name contains our test name
	assert.Contains(t, actualRoleName, "basic-example-role")

	// Verify role exists in AWS
	sess, err := session.NewSession(&aws.Config{Region: aws.String("us-east-1")})
	require.NoError(t, err)

	iamClient := iam.New(sess)
	
	// Get role details
	getRoleInput := &iam.GetRoleInput{
		RoleName: aws.String(actualRoleName),
	}
	
	role, err := iamClient.GetRole(getRoleInput)
	require.NoError(t, err)
	assert.NotNil(t, role.Role)
	assert.Equal(t, actualRoleName, *role.Role.RoleName)

	// Verify assume role policy
	var assumeRolePolicy map[string]interface{}
	err = json.Unmarshal([]byte(*role.Role.AssumeRolePolicyDocument), &assumeRolePolicy)
	require.NoError(t, err)
	
	statements := assumeRolePolicy["Statement"].([]interface{})
	assert.Len(t, statements, 1)
	
	statement := statements[0].(map[string]interface{})
	principal := statement["Principal"].(map[string]interface{})
	assert.Equal(t, "ec2.amazonaws.com", principal["Service"])

	// Verify managed policies are attached
	listAttachedPoliciesInput := &iam.ListAttachedRolePoliciesInput{
		RoleName: aws.String(actualRoleName),
	}
	
	policies, err := iamClient.ListAttachedRolePolicies(listAttachedPoliciesInput)
	require.NoError(t, err)
	assert.Len(t, policies.AttachedPolicies, 1)
	assert.Contains(t, *policies.AttachedPolicies[0].PolicyArn, "AmazonSSMManagedInstanceCore")
}

func TestLambdaExecutionRole(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/lambda-execution",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	roleArn := terraform.Output(t, terraformOptions, "role_arn")
	roleName := terraform.Output(t, terraformOptions, "role_name")
	inlinePolicies := terraform.OutputList(t, terraformOptions, "inline_policies")

	// Verify outputs
	assert.NotEmpty(t, roleArn)
	assert.Contains(t, roleName, "lambda-execution-example-role")
	assert.Len(t, inlinePolicies, 2) // s3_access and dynamodb_access

	// Verify role exists in AWS
	sess, err := session.NewSession(&aws.Config{Region: aws.String("us-east-1")})
	require.NoError(t, err)

	iamClient := iam.New(sess)
	
	// Get role details
	getRoleInput := &iam.GetRoleInput{
		RoleName: aws.String(roleName),
	}
	
	role, err := iamClient.GetRole(getRoleInput)
	require.NoError(t, err)

	// Verify assume role policy contains lambda service
	var assumeRolePolicy map[string]interface{}
	err = json.Unmarshal([]byte(*role.Role.AssumeRolePolicyDocument), &assumeRolePolicy)
	require.NoError(t, err)
	
	statements := assumeRolePolicy["Statement"].([]interface{})
	statement := statements[0].(map[string]interface{})
	principal := statement["Principal"].(map[string]interface{})
	assert.Equal(t, "lambda.amazonaws.com", principal["Service"])

	// Verify managed policies
	listAttachedPoliciesInput := &iam.ListAttachedRolePoliciesInput{
		RoleName: aws.String(roleName),
	}
	
	policies, err := iamClient.ListAttachedRolePolicies(listAttachedPoliciesInput)
	require.NoError(t, err)
	assert.GreaterOrEqual(t, len(policies.AttachedPolicies), 2)

	// Verify inline policies
	listRolePoliciesInput := &iam.ListRolePoliciesInput{
		RoleName: aws.String(roleName),
	}
	
	rolePolicies, err := iamClient.ListRolePolicies(listRolePoliciesInput)
	require.NoError(t, err)
	assert.Len(t, rolePolicies.PolicyNames, 2)

	// Check that inline policy names match expected
	policyNames := make([]string, len(rolePolicies.PolicyNames))
	for i, name := range rolePolicies.PolicyNames {
		policyNames[i] = *name
	}
	assert.Contains(t, policyNames, "s3_access")
	assert.Contains(t, policyNames, "dynamodb_access")
}

func TestCrossAccountRole(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/cross-account",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	roleArn := terraform.Output(t, terraformOptions, "role_arn")
	roleName := terraform.Output(t, terraformOptions, "role_name")
	maxSessionDuration := terraform.Output(t, terraformOptions, "max_session_duration")

	// Verify outputs
	assert.NotEmpty(t, roleArn)
	assert.Contains(t, roleName, "cross-account-example-role")
	assert.Equal(t, "7200", maxSessionDuration) // 2 hours

	// Verify role exists in AWS
	sess, err := session.NewSession(&aws.Config{Region: aws.String("us-east-1")})
	require.NoError(t, err)

	iamClient := iam.New(sess)
	
	// Get role details
	getRoleInput := &iam.GetRoleInput{
		RoleName: aws.String(roleName),
	}
	
	role, err := iamClient.GetRole(getRoleInput)
	require.NoError(t, err)

	// Verify max session duration
	assert.Equal(t, int64(7200), *role.Role.MaxSessionDuration)

	// Verify assume role policy contains AWS principal
	var assumeRolePolicy map[string]interface{}
	err = json.Unmarshal([]byte(*role.Role.AssumeRolePolicyDocument), &assumeRolePolicy)
	require.NoError(t, err)
	
	statements := assumeRolePolicy["Statement"].([]interface{})
	statement := statements[0].(map[string]interface{})
	principal := statement["Principal"].(map[string]interface{})
	awsPrincipal := principal["AWS"].(string)
	assert.Contains(t, awsPrincipal, "123456789012")

	// Verify condition exists for external ID
	condition := statement["Condition"].(map[string]interface{})
	stringEquals := condition["StringEquals"].(map[string]interface{})
	externalId := stringEquals["sts:ExternalId"].(string)
	assert.Equal(t, "unique-external-id-12345", externalId)
}

func TestComprehensiveRole(t *testing.T) {
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
	roleArn := terraform.Output(t, terraformOptions, "role_arn")
	roleName := terraform.Output(t, terraformOptions, "role_name")
	rolePath := terraform.Output(t, terraformOptions, "role_path")
	instanceProfileArn := terraform.Output(t, terraformOptions, "instance_profile_arn")
	inlinePolicies := terraform.OutputList(t, terraformOptions, "inline_policy_names")

	// Verify outputs
	assert.NotEmpty(t, roleArn)
	assert.Contains(t, roleName, "comprehensive-example-role")
	assert.Equal(t, "/application/", rolePath)
	assert.NotEmpty(t, instanceProfileArn)
	assert.Len(t, inlinePolicies, 4) // All inline policies

	// Verify role exists in AWS
	sess, err := session.NewSession(&aws.Config{Region: aws.String("us-east-1")})
	require.NoError(t, err)

	iamClient := iam.New(sess)
	
	// Get role details
	getRoleInput := &iam.GetRoleInput{
		RoleName: aws.String(roleName),
	}
	
	role, err := iamClient.GetRole(getRoleInput)
	require.NoError(t, err)

	// Verify role path
	assert.Equal(t, "/application/", *role.Role.Path)

	// Verify max session duration
	assert.Equal(t, int64(7200), *role.Role.MaxSessionDuration)

	// Verify assume role policy contains multiple services
	var assumeRolePolicy map[string]interface{}
	err = json.Unmarshal([]byte(*role.Role.AssumeRolePolicyDocument), &assumeRolePolicy)
	require.NoError(t, err)
	
	statements := assumeRolePolicy["Statement"].([]interface{})
	assert.Len(t, statements, 2) // Service and AWS principal statements

	// Check for service principal
	serviceStatement := statements[0].(map[string]interface{})
	servicePrincipal := serviceStatement["Principal"].(map[string]interface{})
	services := servicePrincipal["Service"].([]interface{})
	assert.Contains(t, services, "ec2.amazonaws.com")
	assert.Contains(t, services, "lambda.amazonaws.com")

	// Verify managed policies count
	listAttachedPoliciesInput := &iam.ListAttachedRolePoliciesInput{
		RoleName: aws.String(roleName),
	}
	
	policies, err := iamClient.ListAttachedRolePolicies(listAttachedPoliciesInput)
	require.NoError(t, err)
	assert.Len(t, policies.AttachedPolicies, 3)

	// Verify inline policies count
	listRolePoliciesInput := &iam.ListRolePoliciesInput{
		RoleName: aws.String(roleName),
	}
	
	rolePolicies, err := iamClient.ListRolePolicies(listRolePoliciesInput)
	require.NoError(t, err)
	assert.Len(t, rolePolicies.PolicyNames, 4)

	// Verify instance profile exists
	getInstanceProfileInput := &iam.GetInstanceProfileInput{
		InstanceProfileName: aws.String("comprehensive-example-instance-profile"),
	}
	
	instanceProfile, err := iamClient.GetInstanceProfile(getInstanceProfileInput)
	require.NoError(t, err)
	assert.NotNil(t, instanceProfile.InstanceProfile)
	assert.Equal(t, "/application/", *instanceProfile.InstanceProfile.Path)
	assert.Len(t, instanceProfile.InstanceProfile.Roles, 1)
	assert.Equal(t, roleName, *instanceProfile.InstanceProfile.Roles[0].RoleName)
}

func TestRoleValidation(t *testing.T) {
	t.Parallel()

	// Test with invalid assume role policy
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"assume_role_policy": "invalid-json",
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
