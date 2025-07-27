# CloudWatch Monitoring for Application Load Balancer

## Key Metrics to Monitor

### Request Metrics
- **RequestCount**: Total number of requests
- **RequestCountPerTarget**: Requests per target
- **NewConnectionCount**: Number of new connections

### Response Metrics
- **TargetResponseTime**: Response time from targets
- **HTTPCode_Target_2XX_Count**: Successful responses
- **HTTPCode_Target_4XX_Count**: Client error responses
- **HTTPCode_Target_5XX_Count**: Server error responses

### Health Metrics
- **HealthyHostCount**: Number of healthy targets
- **UnHealthyHostCount**: Number of unhealthy targets
- **TargetConnectionErrorCount**: Connection errors to targets

## CloudWatch Alarms Examples

### High Response Time Alarm
```bash
aws cloudwatch put-metric-alarm \
    --alarm-name "USERNAME-ALB-HighResponseTime" \
    --alarm-description "Alert when response time is high" \
    --metric-name TargetResponseTime \
    --namespace AWS/ApplicationELB \
    --statistic Average \
    --period 300 \
    --threshold 1.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2
```

### Unhealthy Targets Alarm
```bash
aws cloudwatch put-metric-alarm \
    --alarm-name "USERNAME-ALB-UnhealthyTargets" \
    --alarm-description "Alert when targets are unhealthy" \
    --metric-name UnHealthyHostCount \
    --namespace AWS/ApplicationELB \
    --statistic Average \
    --period 60 \
    --threshold 0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 1
```

## Useful CLI Commands

### View ALB Status
```bash
aws elbv2 describe-load-balancers --names USERNAME-web-alb
```

### View Target Health
```bash
aws elbv2 describe-target-health --target-group-arn TARGET_GROUP_ARN
```

### View ALB Metrics
```bash
aws cloudwatch get-metric-statistics \
    --namespace AWS/ApplicationELB \
    --metric-name RequestCount \
    --dimensions Name=LoadBalancer,Value=app/USERNAME-web-alb/LOAD_BALANCER_ID \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-01T01:00:00Z \
    --period 300 \
    --statistics Sum
```

