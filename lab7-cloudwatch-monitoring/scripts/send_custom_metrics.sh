#!/bin/bash
# Custom Metrics Script for CloudWatch

echo "Sending custom metrics to CloudWatch..."

# Replace USERNAME with actual username
NAMESPACE="USERNAME/CustomApp"
REGION="us-east-1"

# Send sample application metrics
aws cloudwatch put-metric-data \
    --namespace "$NAMESPACE" \
    --metric-data MetricName=UserLogins,Value=$(shuf -i 1-10 -n 1),Unit=Count \
    --region $REGION

aws cloudwatch put-metric-data \
    --namespace "$NAMESPACE" \
    --metric-data MetricName=ApiResponseTime,Value=$(shuf -i 100-500 -n 1),Unit=Milliseconds \
    --region $REGION

aws cloudwatch put-metric-data \
    --namespace "$NAMESPACE" \
    --metric-data MetricName=DatabaseConnections,Value=$(shuf -i 5-15 -n 1),Unit=Count \
    --region $REGION

echo "Custom metrics sent to CloudWatch namespace: $NAMESPACE"
echo "Check CloudWatch console under Custom Namespaces to view metrics."
