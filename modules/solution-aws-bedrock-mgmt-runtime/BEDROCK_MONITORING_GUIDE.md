# Amazon Bedrock Comprehensive Monitoring Guide

## Overview

This AWS Bedrock Management Runtime solution provides comprehensive CloudWatch monitoring and alerting for all Amazon Bedrock services and metrics. The monitoring covers:

- **Bedrock Runtime Metrics**: Model invocations, latency, errors, throttling, token usage
- **Bedrock Agents**: Agent invocation performance and error monitoring
- **Knowledge Bases**: Retrieval performance and error monitoring  
- **Guardrails**: Content blocking and security monitoring
- **Model Training**: Custom model training job monitoring
- **API Calls**: Overall API usage patterns and anomaly detection
- **Logging Delivery**: CloudWatch and S3 log delivery monitoring

## Monitored Metrics

### 1. Bedrock Runtime Metrics (AWS/Bedrock namespace)

| Metric | Description | Alarm Type | Threshold Variable |
|--------|-------------|------------|-------------------|
| `Invocations` | Successful model invocations | Anomaly Detection | `anomaly_threshold` |
| `InvocationLatency` | P99 latency of invocations | Static Threshold | `latency_threshold_ms` |
| `InvocationClientErrors` | Client-side errors | Static Threshold | `invocation_error_threshold` |
| `InvocationServerErrors` | Server-side errors | Static Threshold | `server_error_threshold` |
| `InvocationThrottles` | Throttled requests | Static Threshold | `throttle_threshold` |
| `InputTokenCount` | Input tokens used | Anomaly Detection | `token_anomaly_threshold` |
| `OutputTokenCount` | Output tokens generated | Anomaly Detection | `token_anomaly_threshold` |
| `OutputImageCount` | Images generated | - | - |
| `LegacyModelInvocations` | Legacy model usage | - | - |

### 2. Bedrock Agents Metrics (AWS/BedrockAgent namespace)

| Metric | Description | Alarm Type | Threshold Variable |
|--------|-------------|------------|-------------------|
| `InvocationClientErrors` | Agent client errors | Static Threshold | `agents_error_threshold` |
| `InvocationServerErrors` | Agent server errors | Static Threshold | `agents_error_threshold` |
| `InvocationLatency` | Agent invocation latency | Static Threshold | `agents_latency_threshold_ms` |
| `InvocationThrottles` | Agent throttling | Static Threshold | `agents_throttle_threshold` |

### 3. Knowledge Base Metrics (AWS/BedrockAgent namespace)

| Metric | Description | Alarm Type | Threshold Variable |
|--------|-------------|------------|-------------------|
| `RetrieveClientErrors` | KB client errors | Static Threshold | `kb_error_threshold` |
| `RetrieveServerErrors` | KB server errors | Static Threshold | `kb_error_threshold` |
| `RetrieveLatency` | KB retrieval latency | Static Threshold | `kb_latency_threshold_ms` |
| `RetrieveThrottles` | KB throttling | Static Threshold | `kb_throttle_threshold` |

### 4. Guardrails Metrics (AWS/Bedrock namespace)

| Metric | Description | Alarm Type | Threshold Variable |
|--------|-------------|------------|-------------------|
| `GuardrailsBlockedInputs` | Blocked input requests | Static Threshold | `guardrails_blocked_threshold` |
| `GuardrailsBlockedOutputs` | Blocked output responses | Static Threshold | `guardrails_blocked_threshold` |

### 5. Logging Delivery Metrics (AWS/Bedrock namespace)

| Metric | Description | Alarm Type | Threshold Variable |
|--------|-------------|------------|-------------------|
| `ModelInvocationLogsCloudWatchDeliverySuccess` | CW delivery success | - | - |
| `ModelInvocationLogsCloudWatchDeliveryFailure` | CW delivery failures | Static Threshold | `logging_failure_threshold` |
| `ModelInvocationLogsS3DeliverySuccess` | S3 delivery success | - | - |
| `ModelInvocationLogsS3DeliveryFailure` | S3 delivery failures | Static Threshold | `logging_failure_threshold` |
| `ModelInvocationLargeDataS3DeliverySuccess` | Large data S3 success | - | - |
| `ModelInvocationLargeDataS3DeliveryFailure` | Large data S3 failures | - | - |

### 6. Training Job Metrics (AWS/Bedrock namespace)

| Metric | Description | Alarm Type | Threshold Variable |
|--------|-------------|------------|-------------------|
| `TrainingJobFailures` | Failed training jobs | Static Threshold | `training_job_failure_threshold` |

### 7. API Usage Metrics (AWS/Bedrock namespace)

| Metric | Description | Alarm Type | Threshold Variable |
|--------|-------------|------------|-------------------|
| `APICallCount` | Overall API call volume | Anomaly Detection | `anomaly_threshold` |

## SNS Topics and Alert Routing

The solution creates three SNS topics for different severity levels:

### 1. Critical Alerts (`bedrock-critical-alerts`)
- **Purpose**: High-priority issues requiring immediate attention
- **Triggers**: Error rates, server failures, logging delivery failures, training job failures
- **Recommended Subscribers**: On-call engineers, operations team, PagerDuty
- **Configuration Variable**: `critical_alert_subscriptions`

### 2. Performance Alerts (`bedrock-performance-alerts`)
- **Purpose**: Performance degradation and throttling issues
- **Triggers**: High latency, throttling, guardrails blocking patterns
- **Recommended Subscribers**: Performance engineering team, application teams
- **Configuration Variable**: `performance_alert_subscriptions`

### 3. Cost Alerts (`bedrock-cost-alerts`)
- **Purpose**: Cost optimization and usage anomalies
- **Triggers**: Token usage anomalies, unexpected usage patterns
- **Recommended Subscribers**: FinOps team, cost management team
- **Configuration Variable**: `cost_alert_subscriptions`

## Composite Alarms

### Basic Health Composite Alarm
- **Name**: `bedrock-overall-health`
- **Purpose**: Overall service health based on core runtime metrics
- **Includes**: Runtime errors, server errors, logging failures

### Comprehensive Health Composite Alarm
- **Name**: `bedrock-comprehensive-health`  
- **Purpose**: Complete service health including all Bedrock services
- **Includes**: Runtime, Agents, Knowledge Bases, Guardrails, Training jobs
- **Configuration**: Enabled via `enable_comprehensive_health_monitoring`

## Monitoring Configuration Variables

### Core Monitoring Controls
```hcl
enable_alerting                          = true   # Master switch for all alerting
enable_anomaly_detection                 = true   # Enable anomaly detection alarms
enable_composite_alarms                  = true   # Enable composite health monitoring
enable_cost_alerting                     = true   # Enable cost-related alerting
enable_token_monitoring                  = true   # Enable token usage monitoring
```

### Service-Specific Monitoring
```hcl
enable_agents_monitoring                 = true   # Bedrock Agents monitoring
enable_knowledge_base_monitoring         = true   # Knowledge Base monitoring
enable_guardrails_monitoring             = true   # Guardrails monitoring
enable_training_monitoring               = true   # Model training monitoring
enable_api_call_monitoring               = true   # API call monitoring
enable_comprehensive_health_monitoring   = true   # All-services health monitoring
```

### Threshold Configuration
```hcl
# Error thresholds
invocation_error_threshold     = 10    # Runtime client errors
server_error_threshold         = 5     # Runtime server errors
agents_error_threshold         = 5     # Agents errors
kb_error_threshold            = 5     # Knowledge Base errors

# Latency thresholds (milliseconds)
latency_threshold_ms          = 10000  # Runtime latency
agents_latency_threshold_ms   = 15000  # Agents latency
kb_latency_threshold_ms       = 5000   # Knowledge Base latency

# Throttling thresholds
throttle_threshold            = 20     # Runtime throttling
agents_throttle_threshold     = 10     # Agents throttling
kb_throttle_threshold         = 10     # Knowledge Base throttling

# Security and logging thresholds
guardrails_blocked_threshold  = 50     # Guardrails blocking
logging_failure_threshold     = 1      # Log delivery failures
training_job_failure_threshold = 0     # Training job failures
```

### Alarm Timing Configuration
```hcl
alarm_evaluation_periods      = 2      # Periods to evaluate
alarm_datapoints_to_alarm    = 2      # Datapoints needed to alarm
alarm_period                 = 300    # Period length (seconds)

# Anomaly detection specific
anomaly_evaluation_periods   = 2      # Anomaly evaluation periods
anomaly_period              = 300    # Anomaly period (seconds)
anomaly_threshold           = 2      # Anomaly threshold multiplier
token_anomaly_threshold     = 2      # Token anomaly threshold
```

## Maintenance Windows and Action Suppression

The solution supports maintenance window configurations to suppress alarm actions during planned maintenance:

```hcl
maintenance_window_alarm_arn = "arn:aws:cloudwatch:region:account:alarm:maintenance-window"
maintenance_suppression_extension_period = 300  # Extension period (seconds)
maintenance_suppression_wait_period = 300       # Wait period (seconds)
```

When configured, composite alarms will include action suppression during maintenance windows.

## Cost Optimization

### Monitoring Costs
- CloudWatch alarms: ~$0.10 per alarm per month
- SNS notifications: ~$0.50 per million notifications
- CloudWatch Logs: Based on ingestion and storage

### Cost Control Variables
```hcl
enable_ok_actions = false  # Disable OK notifications to reduce SNS costs
```

### Recommended Cost Settings for Production
- Enable all critical monitoring
- Use selective service monitoring based on usage
- Configure appropriate alarm thresholds to avoid noise
- Use action suppression during maintenance windows

## Security and Compliance

### Encryption
- SNS topics encrypted with KMS (configurable via `enable_sns_encryption`)
- CloudWatch Logs encrypted with KMS
- S3 bucket encryption enforced

### IAM Permissions
- Least privilege access for CloudWatch and SNS
- Service-linked roles for AWS services
- Cross-service permissions properly scoped

### Compliance Features
- All metrics retained according to `retention_days` setting
- Audit trails through CloudTrail integration
- Immutable logging to S3 with bucket policies

## Troubleshooting Guide

### Common Issues

1. **No Metrics Appearing**
   - Verify Bedrock service is actively used
   - Check CloudWatch permissions
   - Ensure metrics namespace is correct

2. **False Positive Alarms**
   - Adjust thresholds based on baseline
   - Consider increasing evaluation periods
   - Review anomaly detection sensitivity

3. **Missing Notifications**
   - Verify SNS subscription confirmation
   - Check SNS topic policies
   - Validate email/SMS endpoints

4. **High Costs**
   - Reduce alarm frequency where appropriate
   - Disable OK actions if not needed
   - Use selective monitoring for less critical services

### Monitoring Health Checks

Use these CloudWatch Insights queries to validate monitoring:

```sql
# Check alarm state distribution
fields @timestamp, AlarmName, NewStateValue
| filter @message like /ALARM/
| stats count() by NewStateValue
```

```sql
# Monitor SNS delivery success
fields @timestamp, @message
| filter @logStream like /aws/sns/
| filter @message like /delivery/
```

## Best Practices

### Threshold Tuning
1. Start with recommended defaults
2. Monitor for 1-2 weeks to establish baseline
3. Adjust thresholds based on normal operational patterns
4. Review and tune quarterly

### Alert Fatigue Prevention
1. Use appropriate severity levels (Critical vs Warning vs Info)
2. Implement action suppression during maintenance
3. Group related alarms using composite alarms
4. Regular review of alarm effectiveness

### Operational Procedures
1. Define clear escalation procedures for each alert type
2. Create runbooks for common alarm scenarios
3. Regular testing of notification delivery
4. Quarterly review of monitoring effectiveness

### Scaling Considerations
1. Monitor CloudWatch API limits
2. Consider regional distribution for large deployments
3. Use tag-based filtering for multi-tenant scenarios
4. Implement automated threshold adjustment for dynamic workloads

This comprehensive monitoring solution provides enterprise-grade observability for Amazon Bedrock deployments, ensuring high availability, performance, and cost optimization.
