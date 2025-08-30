package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBedrockModelInvocationLoggingS3(t *testing.T) {
	// Configure Terraform options with the path to the S3 logging example
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/s3-logging",
		Vars: map[string]interface{}{
			"bucket_name_prefix": "test-bedrock-logs",
			"s3_key_prefix":      "test-logs",
			"aws_region":         "us-east-1",
			"enable_video_data":  false, // Disable video for testing
		},
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Verify the logging configuration was created successfully
	loggingConfigId := terraform.Output(t, terraformOptions, "logging_configuration_id")
	s3BucketName := terraform.Output(t, terraformOptions, "s3_bucket_name")
	s3KeyPrefix := terraform.Output(t, terraformOptions, "s3_key_prefix")
	accountId := terraform.Output(t, terraformOptions, "account_id")
	awsRegion := terraform.Output(t, terraformOptions, "aws_region")

	// Assert that outputs are not empty
	assert.NotEmpty(t, loggingConfigId)
	assert.NotEmpty(t, s3BucketName)
	assert.Equal(t, "test-logs", s3KeyPrefix)
	assert.NotEmpty(t, accountId)
	assert.Equal(t, "us-east-1", awsRegion)
	assert.Equal(t, "us-east-1", loggingConfigId) // ID should be the region

	// Assert bucket name contains expected prefix
	assert.Contains(t, s3BucketName, "test-bedrock-logs")
}

func TestBedrockModelInvocationLoggingCloudWatch(t *testing.T) {
	// Configure Terraform options with the path to the CloudWatch logging example
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/cloudwatch-logging",
		Vars: map[string]interface{}{
			"resource_prefix":     "test-bedrock-cw",
			"log_group_name":      "/aws/bedrock/test-model-invocations",
			"log_retention_days":  7,
			"aws_region":          "us-east-1",
			"enable_video_data":   false,
		},
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Verify the logging configuration was created successfully
	loggingConfigId := terraform.Output(t, terraformOptions, "logging_configuration_id")
	logGroupName := terraform.Output(t, terraformOptions, "cloudwatch_log_group_name")
	logGroupArn := terraform.Output(t, terraformOptions, "cloudwatch_log_group_arn")
	iamRoleArn := terraform.Output(t, terraformOptions, "iam_role_arn")
	logRetentionDays := terraform.Output(t, terraformOptions, "log_retention_days")

	// Assert that outputs are not empty and correct
	assert.Equal(t, "us-east-1", loggingConfigId)
	assert.Equal(t, "/aws/bedrock/test-model-invocations", logGroupName)
	assert.NotEmpty(t, logGroupArn)
	assert.NotEmpty(t, iamRoleArn)
	assert.Equal(t, "7", logRetentionDays)

	// Assert ARNs contain expected components
	assert.Contains(t, logGroupArn, "arn:aws:logs:us-east-1")
	assert.Contains(t, logGroupArn, "log-group:/aws/bedrock/test-model-invocations")
	assert.Contains(t, iamRoleArn, "arn:aws:iam::")
	assert.Contains(t, iamRoleArn, "role/test-bedrock-cw-bedrock-cloudwatch-role")
}

func TestBedrockModelInvocationLoggingHybrid(t *testing.T) {
	// Configure Terraform options with the path to the hybrid logging example
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/hybrid-logging",
		Vars: map[string]interface{}{
			"resource_prefix":         "test-hybrid",
			"bucket_name_prefix":      "test-hybrid-bedrock",
			"log_group_name":          "/aws/bedrock/test-hybrid-invocations",
			"s3_key_prefix":           "standard-logs",
			"large_data_key_prefix":   "large-data-logs",
			"aws_region":              "us-east-1",
			"log_retention_days":      14,
		},
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Verify the hybrid logging configuration was created successfully
	loggingConfigId := terraform.Output(t, terraformOptions, "logging_configuration_id")
	s3LogsBucket := terraform.Output(t, terraformOptions, "s3_logs_bucket_name")
	s3LargeDataBucket := terraform.Output(t, terraformOptions, "s3_large_data_bucket_name")
	logGroupName := terraform.Output(t, terraformOptions, "cloudwatch_log_group_name")
	iamRoleArn := terraform.Output(t, terraformOptions, "iam_role_arn")

	// Assert that outputs are not empty
	assert.Equal(t, "us-east-1", loggingConfigId)
	assert.NotEmpty(t, s3LogsBucket)
	assert.NotEmpty(t, s3LargeDataBucket)
	assert.Equal(t, "/aws/bedrock/test-hybrid-invocations", logGroupName)
	assert.NotEmpty(t, iamRoleArn)

	// Assert bucket names contain expected prefix
	assert.Contains(t, s3LogsBucket, "test-hybrid-bedrock-logs")
	assert.Contains(t, s3LargeDataBucket, "test-hybrid-bedrock-large-data")

	// Assert buckets are different
	assert.NotEqual(t, s3LogsBucket, s3LargeDataBucket)
}
