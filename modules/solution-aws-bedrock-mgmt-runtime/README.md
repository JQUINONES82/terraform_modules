# AWS Bedrock Management Runtime Solution

A comprehensive, enterprise-grade AWS Bedrock deployment solution that implements security best practices following Trend Micro recommendations and includes comprehensive CloudWatch monitoring for all Bedrock services.

## 🏗️ Architecture Overview

This solution provides a secure, production-ready AWS Bedrock environment with:

- **Secure Network Architecture**: VPC endpoints with network segmentation
- **Comprehensive Encryption**: Customer-managed KMS keys for all data at rest and in transit
- **Content Safety**: Guardrails with PII masking and content filtering
- **Audit & Compliance**: Complete logging with CloudWatch and S3
- **Access Control**: Least privilege IAM policies and network restrictions
- **Security Hardening**: Following Trend Micro Bedrock security recommendations
- **🆕 Comprehensive Monitoring**: CloudWatch alarms for all Bedrock services, metrics, and operational health

## 🔒 Security Features

### Trend Micro Compliance
- ✅ **Customer-Managed KMS Keys**: All encryption uses CMKs
- ✅ **Model Invocation Logging**: Complete audit trail enabled
- ✅ **Guardrails Protection**: HIGH strength content filters
- ✅ **PII Masking**: Sensitive information anonymization
- ✅ **Cross-Service Confused Deputy Prevention**: Secure service-to-service access
- ✅ **Permissions Boundaries**: Enhanced IAM security
- ✅ **VPC Isolation**: Network segmentation with private endpoints
- ✅ **Secure Transport**: HTTPS/TLS enforcement

### Network Security
- **Management Endpoint**: Restricted to `10.20.0.0/8` on port 443
- **Runtime Endpoint**: Limited to `10.30.0.0/16` and `10.40.0.0/16`
- **General Services**: VPC CIDR access only
- **Private DNS**: Internal resolution for all endpoints

### Data Protection
- **Encryption at Rest**: KMS encryption for S3, CloudWatch, guardrails
- **Encryption in Transit**: TLS 1.2+ enforcement
- **Log Retention**: Configurable CloudWatch log retention
- **S3 Lifecycle**: Automated data archival and cost optimization

## � Monitoring & Alerting

### Comprehensive CloudWatch Monitoring
This solution includes extensive monitoring for all Amazon Bedrock services:

#### Runtime Metrics
- **Invocations**: Model usage patterns and anomaly detection
- **Latency**: P99 latency monitoring (default: 10s threshold)
- **Errors**: Client and server error monitoring
- **Throttling**: Rate limiting and capacity monitoring
- **Token Usage**: Input/output token consumption anomaly detection

#### Bedrock Agents Monitoring
- **Agent Invocations**: Performance and error monitoring
- **Agent Latency**: P99 latency tracking (default: 15s threshold)
- **Agent Throttling**: Capacity and rate limiting monitoring

#### Knowledge Base Monitoring
- **Retrieval Performance**: Query latency monitoring (default: 5s threshold)
- **Retrieval Errors**: Success/failure rate tracking
- **Retrieval Throttling**: Capacity monitoring

#### Guardrails Monitoring
- **Blocked Inputs/Outputs**: Security event monitoring
- **Content Safety**: PII and harmful content detection rates

#### Additional Monitoring
- **Training Jobs**: Custom model training failure detection
- **API Calls**: Overall API usage anomaly detection
- **Log Delivery**: CloudWatch and S3 delivery monitoring

### SNS Alert Topics
- **Critical Alerts**: High-priority issues (errors, failures)
- **Performance Alerts**: Latency and throttling issues
- **Cost Alerts**: Usage anomalies and cost optimization

### Composite Health Monitoring
- **Basic Health**: Core runtime metrics
- **Comprehensive Health**: All Bedrock services combined

For detailed monitoring configuration, see [BEDROCK_MONITORING_GUIDE.md](./BEDROCK_MONITORING_GUIDE.md).

## �🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- VPC and subnets already created

### Basic Deployment

```hcl
module "bedrock_solution" {
  source = "./modules/solution-aws-bedrock-mgmt-runtime"

  environment = "production"
  vpc_id      = "vpc-0123456789abcdef"
  subnet_ids  = ["snet-0123456789a", "snet-0123456789b"]

  # Security configuration
  management_allowed_cidrs = ["10.20.0.0/8"]
  runtime_allowed_cidrs    = ["10.30.0.0/16", "10.40.0.0/16"]
  vpc_cidr                 = "10.0.0.0/16"

  # Bedrock configuration
  bedrock_role_name = "JQ-12345678-Bedrock"
  
  # Monitoring configuration
  enable_alerting = true
  critical_alert_subscriptions = {
    "ops-team" = {
      protocol = "email"
      endpoint = "ops-team@company.com"
    }
  }
  
  tags = {
    Project     = "AI-Platform"
    Owner       = "Platform-Team"
    Environment = "production"
  }
}
```

### Advanced Configuration with Comprehensive Monitoring

```hcl
module "bedrock_solution" {
  source = "./modules/solution-aws-bedrock-mgmt-runtime"

  environment = "production"
  vpc_id      = "vpc-0123456789abcdef"
  subnet_ids  = ["snet-0123456789a", "snet-0123456789b"]

  # Comprehensive logging
  log_retention_days = 90
  enable_s3_logging  = true
  s3_log_prefix      = "bedrock-invocations/"

  # Enhanced guardrails
  enable_guardrails    = true
  pii_entities_action  = "ANONYMIZE"
  
  content_filters = {
    sexual = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    violence = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    hate = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    prompt_attack = {
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
  }

  # Comprehensive monitoring configuration
  enable_alerting                        = true
  enable_anomaly_detection               = true
  enable_composite_alarms                = true
  enable_agents_monitoring               = true
  enable_knowledge_base_monitoring       = true
  enable_guardrails_monitoring           = true
  enable_training_monitoring             = true
  enable_api_call_monitoring             = true
  enable_comprehensive_health_monitoring = true

  # Threshold configuration
  invocation_error_threshold      = 10
  server_error_threshold         = 5
  agents_error_threshold         = 5
  kb_error_threshold            = 5
  latency_threshold_ms          = 10000
  agents_latency_threshold_ms   = 15000
  kb_latency_threshold_ms       = 5000
  throttle_threshold            = 20
  agents_throttle_threshold     = 10
  kb_throttle_threshold         = 10
  guardrails_blocked_threshold  = 50

  # SNS alert subscriptions
  critical_alert_subscriptions = {
    "ops-team-email" = {
      protocol = "email"
      endpoint = "ops-team@company.com"
    }
    "ops-team-sms" = {
      protocol = "sms"
      endpoint = "+1234567890"
    }
  }

  performance_alert_subscriptions = {
    "performance-team" = {
      protocol = "email"
      endpoint = "performance-team@company.com"
    }
  }

  cost_alert_subscriptions = {
    "finops-team" = {
      protocol = "email" 
      endpoint = "finops-team@company.com"
    }
  }

  # Multi-region model access
  allowed_model_regions = ["us-east-1", "us-east-2", "us-west-2"]
  
  # Custom foundation models
  foundation_models = [
    "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-5-sonnet-20240620-v1:0",
    "arn:aws:bedrock:us-west-2::foundation-model/amazon.titan-text-express-v1:0"
  ]

  # Security hardening
  permissions_boundary_arn = "arn:aws:iam::123456789012:policy/DeveloperBoundary"
  
  tags = {
    Project      = "AI-Platform"
    Owner        = "Platform-Team"
    Environment  = "production"
    Compliance   = "SOC2-Type2"
    DataClass    = "Confidential"
  }
}
```

## 🏗️ Components

### Core Infrastructure
- **KMS Key**: Customer-managed key with automatic rotation
- **S3 Bucket**: Encrypted logging storage with lifecycle policies
- **CloudWatch Logs**: Real-time log monitoring and alerting
- **IAM Roles/Policies**: Least privilege access controls

### Network Security
- **Security Groups**: Layer 4 network controls
- **VPC Endpoints**: Private connectivity to Bedrock services
- **Endpoint Policies**: Fine-grained API access controls

### Bedrock Services
- **Management Endpoint**: Control plane operations
- **Runtime Endpoint**: Model invocation and inference
- **Agent Endpoints**: Bedrock Agents functionality
- **Guardrails**: Content safety and PII protection

### Monitoring & Compliance
- **Model Invocation Logging**: Complete audit trail
- **CloudWatch Integration**: Metrics and alerting
- **S3 Archival**: Long-term log retention
- **Security Policies**: Encryption and transport security

## 📊 Monitoring

### CloudWatch Metrics
- VPC Endpoint health and performance
- S3 bucket access patterns
- KMS key usage statistics
- Security group traffic analysis

### Log Analysis
- Model invocation patterns
- Content filter activations
- PII detection events
- Access control violations

### Alerting
- Failed API calls
- Unusual access patterns
- Guardrail violations
- Encryption key rotation events

## 🔧 Configuration

### Required Variables
- `environment`: Deployment environment
- `vpc_id`: Target VPC identifier
- `subnet_ids`: VPC endpoint subnet placement

### Network Configuration
- `management_allowed_cidrs`: CIDR blocks for management access
- `runtime_allowed_cidrs`: CIDR blocks for runtime access
- `vpc_cidr`: VPC CIDR block for general access

### Security Configuration
- `bedrock_role_name`: IAM role for Bedrock access
- `permissions_boundary_arn`: IAM permissions boundary
- `allowed_model_regions`: Permitted model regions

### Content Safety
- `enable_guardrails`: Enable content filtering
- `pii_entities_action`: PII handling (BLOCK/ANONYMIZE)
- `content_filters`: Content filter strength settings

## 🛡️ Security Considerations

### IAM Security
- All roles include confused deputy prevention
- Permissions boundaries applied to all roles
- Least privilege access principles
- Regular access reviews recommended

### Network Security
- All traffic encrypted in transit
- VPC endpoints prevent internet egress
- Security groups implement micro-segmentation
- Private DNS resolution within VPC

### Data Protection
- Customer-managed KMS keys for all encryption
- S3 bucket policies enforce secure transport
- CloudWatch logs encrypted at rest
- Automated key rotation enabled

### Compliance
- GDPR: PII anonymization available
- SOC 2: Comprehensive audit logging
- HIPAA: Encryption and access controls
- ISO 27001: Security configuration standards

## 📋 Outputs

### Infrastructure
- KMS key ARN and alias
- S3 bucket name and ARN
- CloudWatch log group details
- IAM role and policy ARNs

### Network
- VPC endpoint IDs and DNS entries
- Security group identifiers
- Network configuration summary

### Security
- Guardrail ID and version
- Encryption status indicators
- Compliance feature flags

## 🔄 Lifecycle Management

### Updates
1. Test in non-production environment
2. Review security configurations
3. Update guardrail rules if needed
4. Apply with Terraform plan review

### Backup & Recovery
- S3 versioning enabled for logs
- KMS key backup via AWS Backup
- Infrastructure as Code in version control
- Documented recovery procedures

### Cost Optimization
- S3 lifecycle policies for log archival
- CloudWatch log retention policies
- VPC endpoint usage monitoring
- Regular cost analysis reviews

## 🆘 Troubleshooting

### Common Issues
- **VPC Endpoint DNS**: Ensure private DNS is enabled
- **IAM Permissions**: Check confused deputy prevention conditions
- **Network Access**: Verify security group rules
- **KMS Access**: Confirm key policy permissions

### Support Resources
- AWS Bedrock documentation
- Trend Micro security guidelines
- Module documentation in respective folders
- AWS Support for service-specific issues

## 📝 License

This solution is provided under the MIT License. See LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test thoroughly in isolated environment
4. Submit pull request with detailed description
5. Ensure security review approval

---

**⚠️ Security Notice**: This solution implements enterprise security controls. Review all configurations in your security/compliance context before production deployment.
