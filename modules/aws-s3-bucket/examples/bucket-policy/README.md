# S3 Bucket Policy Examples

This example demonstrates various S3 bucket policy scenarios using the aws-s3-bucket module.

## What This Example Creates

This example creates five different S3 buckets, each demonstrating a different bucket policy pattern:

### 1. Public Read-Only Bucket
- **Use Case**: Static website hosting, public file sharing
- **Policy**: Allows public read access to all objects
- **Security**: Public access blocking disabled for read access

### 2. Restricted Access Bucket
- **Use Case**: Application-specific storage with IAM role access
- **Policy**: Only allows access from a specific IAM role
- **Security**: Full public access blocking enabled

### 3. CloudFront Origin Access Control (OAC) Bucket
- **Use Case**: Content delivery via CloudFront
- **Policy**: Allows access only from CloudFront service
- **Security**: Uses Origin Access Control for secure content delivery

### 4. Cross-Account Access Bucket
- **Use Case**: Sharing data between AWS accounts
- **Policy**: Allows specific external AWS account to access objects
- **Security**: Conditional access with encryption requirements

### 5. Conditional Access Bucket
- **Use Case**: High-security environments with IP and MFA restrictions
- **Policy**: Requires MFA and specific IP ranges
- **Security**: Multiple conditions for access control

## Usage

1. **Update Variables**: Modify the variables in `main.tf`:
   ```hcl
   variable "trusted_account_id" {
     default = "YOUR_TRUSTED_ACCOUNT_ID"
   }
   
   variable "allowed_ip_ranges" {
     default = ["YOUR_IP_RANGE/24"]
   }
   ```

2. **Deploy the Example**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Test the Policies**: Each bucket will have different access patterns based on its policy.

## Security Considerations

- **Public Read Bucket**: Only enable public access when necessary
- **Restricted Access**: Use least privilege principle for IAM roles
- **CloudFront OAC**: Preferred over legacy Origin Access Identity (OAI)
- **Cross-Account**: Always validate external account IDs
- **Conditional Access**: Regularly review IP ranges and MFA requirements

## Cleanup

```bash
terraform destroy
```

## Policy Examples Explained

### Public Read Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::bucket-name/*"
    }
  ]
}
```

### CloudFront OAC Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontServicePrincipal",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::bucket-name/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::account:distribution/ID"
        }
      }
    }
  ]
}
```

### Conditional Access Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::account:root"},
      "Action": "s3:*",
      "Resource": ["arn:aws:s3:::bucket-name", "arn:aws:s3:::bucket-name/*"],
      "Condition": {
        "IpAddress": {"aws:SourceIp": "203.0.113.0/24"},
        "Bool": {"aws:MultiFactorAuthPresent": "true"}
      }
    }
  ]
}
```

## Best Practices

1. **Principle of Least Privilege**: Grant only necessary permissions
2. **Use Conditions**: Add IP, MFA, or encryption requirements when appropriate
3. **Regular Audits**: Review and update policies regularly
4. **Test Policies**: Validate access patterns after deployment
5. **Monitor Access**: Use CloudTrail and S3 access logs for monitoring
