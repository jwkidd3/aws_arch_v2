#!/bin/bash

# Script to send custom metrics to CloudWatch
# Replace USERNAME with your assigned username

USERNAME="USERNAME"  # UPDATE THIS

if [ "$USERNAME" = "USERNAME" ]; then
    echo "Error: Please update USERNAME in this script with your assigned username (e.g., user1, user2, user3)"
    exit 1
fi

echo "Sending custom metrics for user: $USERNAME"

# System metrics
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.2f", $3/$2 * 100.0}')
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)

echo "Current system metrics:"
echo "  CPU Usage: $CPU_USAGE%"
echo "  Memory Usage: $MEMORY_USAGE%"
echo "  Disk Usage: $DISK_USAGE%"

# Send metrics to CloudWatch
aws cloudwatch put-metric-data \
    --namespace "$USERNAME/System" \
    --metric-data MetricName=CPUUsage,Value=$CPU_USAGE,Unit=Percent,Dimensions=Instance=Primary

aws cloudwatch put-metric-data \
    --namespace "$USERNAME/System" \
    --metric-data MetricName=MemoryUsage,Value=$MEMORY_USAGE,Unit=Percent,Dimensions=Instance=Primary

aws cloudwatch put-metric-data \
    --namespace "$USERNAME/System" \
    --metric-data MetricName=DiskUsage,Value=$DISK_USAGE,Unit=Percent,Dimensions=Instance=Primary

# Application metrics (simulated)
USER_COUNT=$((RANDOM % 100 + 1))
RESPONSE_TIME=$((RANDOM % 500 + 50))
ERROR_COUNT=$((RANDOM % 10))

aws cloudwatch put-metric-data \
    --namespace "$USERNAME/Application" \
    --metric-data MetricName=ActiveUsers,Value=$USER_COUNT,Unit=Count

aws cloudwatch put-metric-data \
    --namespace "$USERNAME/Application" \
    --metric-data MetricName=ResponseTime,Value=$RESPONSE_TIME,Unit=Milliseconds

aws cloudwatch put-metric-data \
    --namespace "$USERNAME/Application" \
    --metric-data MetricName=ErrorCount,Value=$ERROR_COUNT,Unit=Count

echo "Custom metrics sent successfully!"
echo "Check CloudWatch Console -> Metrics -> Custom Namespaces"
