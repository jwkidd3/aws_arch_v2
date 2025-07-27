# Lab 10 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: CloudWatch Dashboard Creation
- [ ] Verified existing EC2 instances or launched test instance
- [ ] Generated CPU and system activity for monitoring
- [ ] Created CloudWatch dashboard: `USERNAME-monitoring-dashboard`
- [ ] Added CPU utilization widget for EC2 instance
- [ ] Added network I/O and status check widgets
- [ ] Added number widget for instance status monitoring
- [ ] Added text widget with documentation
- [ ] Organized widgets in logical dashboard layout
- [ ] Successfully saved and verified dashboard functionality

### Task 2: CloudWatch Alarms and SNS Configuration
- [ ] Created SNS topic: `USERNAME-monitoring-alerts` (with your username)
- [ ] Set up email subscription and confirmed via email
- [ ] Created CPU utilization alarm: `USERNAME-high-cpu-alarm`
- [ ] Configured alarm threshold (>80% CPU for 5 minutes)
- [ ] Created status check alarm: `USERNAME-status-check-alarm`
- [ ] Created network traffic alarm: `USERNAME-high-network-alarm`
- [ ] Tested alarm functionality by generating high CPU load
- [ ] Verified alarm state changes (OK → ALARM)
- [ ] Received email notifications for triggered alarms
- [ ] Stopped test load and confirmed alarm recovery

### Task 3: CloudWatch Logs and Custom Metrics
- [ ] Installed CloudWatch agent (optional exercise)
- [ ] Configured basic CloudWatch agent settings
- [ ] Sent custom metrics via AWS CLI
- [ ] Verified custom metrics in CloudWatch console
- [ ] Added custom metrics to dashboard
- [ ] Explored CloudWatch Logs Insights (if logs available)
- [ ] Understood custom metric namespaces and dimensions

### Advanced Exercises (Optional)
- [ ] Created CloudWatch Event Rules for automated responses
- [ ] Expanded dashboard with multi-service widgets
- [ ] Set up billing alerts for cost monitoring
- [ ] Configured automated remediation actions

### Cleanup
- [ ] Deleted all CloudWatch alarms with username prefix
- [ ] Removed SNS topic and subscriptions
- [ ] Deleted custom CloudWatch dashboard
- [ ] Terminated test instances if created for this lab
- [ ] Verified all custom resources removed

## Notes

**Your Username:** ________________

**Resource Names (with your username):**
- Dashboard: ________________-monitoring-dashboard
- SNS Topic: ________________-monitoring-alerts
- CPU Alarm: ________________-high-cpu-alarm
- Status Alarm: ________________-status-check-alarm
- Network Alarm: ________________-high-network-alarm

**Instances Monitored:**
- Instance ID: ________________
- Instance Name: ________________
- Public IP: ________________

**Custom Metrics Created:**
- Namespace: ________________/Application
- Metrics: ________________

**Alarm Testing Results:**
- CPU alarm triggered: Yes/No
- Email notification received: Yes/No
- Alarm recovery time: ________________

**Issues Encountered:**


**Solutions Applied:**


**Key Insights:**


**Dashboard Performance:**


**Time Completed:** ________________

