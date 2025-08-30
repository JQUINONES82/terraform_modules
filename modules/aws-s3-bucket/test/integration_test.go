//go:build integration

package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/stretchr/testify/assert"
)

func TestTerraformSimpleExample(t *testing.T) {
	t.Parallel()

	// Pick a random AWS region to test in
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/simple",
		Vars: map[string]interface{}{
			"bucket_prefix": "terratest-simple",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Validate the output
	bucketID := terraform.Output(t, terraformOptions, "result")
	assert.NotEmpty(t, bucketID)
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
	bucketID := terraform.Output(t, terraformOptions, "bucket_id")
	bucketARN := terraform.Output(t, terraformOptions, "bucket_arn")
	websiteEndpoint := terraform.Output(t, terraformOptions, "website_endpoint")

	assert.NotEmpty(t, bucketID)
	assert.NotEmpty(t, bucketARN)
	assert.NotEmpty(t, websiteEndpoint)
	assert.Contains(t, bucketARN, "arn:aws:s3:::")
	assert.Contains(t, websiteEndpoint, ".s3-website")
}

func TestTerraformStaticWebsiteExample(t *testing.T) {
	t.Parallel()

	// Pick a random AWS region to test in
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/static-website",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Validate the outputs
	bucketID := terraform.Output(t, terraformOptions, "bucket_id")
	bucketARN := terraform.Output(t, terraformOptions, "bucket_arn")
	websiteEndpoint := terraform.Output(t, terraformOptions, "website_endpoint")

	assert.NotEmpty(t, bucketID)
	assert.NotEmpty(t, bucketARN)
	assert.NotEmpty(t, websiteEndpoint)
	assert.Contains(t, bucketARN, "arn:aws:s3:::")
}

func TestTerraformBucketPolicyExample(t *testing.T) {
	t.Parallel()

	// Pick a random AWS region to test in
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/bucket-policy",
		Vars: map[string]interface{}{
			"trusted_account_id": "123456789012", // Example account ID
			"allowed_ip_ranges":  []string{"203.0.113.0/24"},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Validate the outputs
	publicReadBucket := terraform.OutputMap(t, terraformOptions, "public_read_bucket")
	restrictedBucket := terraform.OutputMap(t, terraformOptions, "restricted_access_bucket")
	cloudfrontBucket := terraform.OutputMap(t, terraformOptions, "cloudfront_oac_bucket")
	crossAccountBucket := terraform.OutputMap(t, terraformOptions, "cross_account_bucket")
	conditionalBucket := terraform.OutputMap(t, terraformOptions, "conditional_access_bucket")

	// Validate all buckets have proper IDs and ARNs
	assert.NotEmpty(t, publicReadBucket["id"])
	assert.NotEmpty(t, publicReadBucket["arn"])
	assert.Contains(t, publicReadBucket["arn"], "arn:aws:s3:::")

	assert.NotEmpty(t, restrictedBucket["id"])
	assert.NotEmpty(t, restrictedBucket["arn"])
	assert.Contains(t, restrictedBucket["arn"], "arn:aws:s3:::")

	assert.NotEmpty(t, cloudfrontBucket["id"])
	assert.NotEmpty(t, cloudfrontBucket["arn"])
	assert.Contains(t, cloudfrontBucket["arn"], "arn:aws:s3:::")
	assert.NotEmpty(t, cloudfrontBucket["cloudfront_domain_name"])

	assert.NotEmpty(t, crossAccountBucket["id"])
	assert.NotEmpty(t, crossAccountBucket["arn"])
	assert.Contains(t, crossAccountBucket["arn"], "arn:aws:s3:::")

	assert.NotEmpty(t, conditionalBucket["id"])
	assert.NotEmpty(t, conditionalBucket["arn"])
	assert.Contains(t, conditionalBucket["arn"], "arn:aws:s3:::")
}
