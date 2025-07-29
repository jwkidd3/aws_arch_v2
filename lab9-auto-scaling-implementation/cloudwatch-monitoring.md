# CloudWatch Monitoring for Auto Scaling

## Key Metrics to Monitor

### Auto Scaling Group Metrics
- **GroupMinSize**: Minimum group size
- **GroupMaxSize**: Maximum group size
- **GroupDesiredCapacity**: Desired capacity
- **GroupInServiceInstances**: Running instances
- **GroupPendingInstances**: Launching instances
- **GroupStandbyInstances**: Standby instances
- **GroupTerminatingInstances**: Terminating instances
- **GroupTotalInstances**: Total instances

### EC2 Instance Metrics
- **CPUUtilization**: CPU usage percentage
- **NetworkIn/NetworkOut**: Network traffic
- **DiskReadOps/DiskWriteOps**: Disk operations

## Setting Up Custom Alarms

### Scale-Out Alarm
```bash
aws cloudwatch put-metric-alarm \
    --alarm-name "USERNAME-ASG-ScaleOut" \
    --alarm-description "Trigger scale out when CPU > 70%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 70 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=AutoScalingGroupName,Value=USERNAME-asg \
    --evaluation-periods 2
```

### Scale-In Alarm
```bash
aws cloudwatch put-metric-alarm \
    --alarm-name "USERNAME-ASG-ScaleIn" \
    --alarm-description "Trigger scale in when CPU < 30%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 30 \
    --comparison-operator LessThanThreshold \
    --dimensions Name=AutoScalingGroupName,Value=USERNAME-asg \
    --evaluation-periods 2
```

## Custom Dashboard

Create a CloudWatch dashboard to monitor:
- Auto Scaling group capacity trends
- CPU utilization across instances
- Load balancer request count
- Target group healthy host count

## Scaling Activity Logs

Monitor scaling activities through:
- Auto Scaling Groups console Activity tab
- CloudTrail for API calls
- CloudWatch Logs for application logs

