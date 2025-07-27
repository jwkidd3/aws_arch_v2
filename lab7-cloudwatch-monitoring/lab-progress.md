# Lab 7 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: Infrastructure Setup for Monitoring
- [ ] Launched EC2 instance with detailed monitoring: `USERNAME-monitoring-target`
- [ ] Configured security group: `USERNAME-monitoring-sg` (with your username)
- [ ] Applied user data script for monitoring setup
- [ ] Verified instance reaches running state
- [ ] Tested web interface accessibility
- [ ] Confirmed initial CloudWatch metrics collection

### Task 2: Create Custom CloudWatch Dashboard
- [ ] Created CloudWatch dashboard: `USERNAME-monitoring-dashboard`
- [ ] Added CPU Utilization line chart widget
- [ ] Added Network Traffic number widget
- [ ] Added Status Checks line chart widget
- [ ] Added Disk Operations gauge widget
- [ ] Configured proper widget titles with username
- [ ] Saved dashboard successfully
- [ ] Verified all widgets display real data

### Task 3: Configure CloudWatch Alarms with SNS
- [ ] Created SNS topic: `USERNAME-cloudwatch-alerts` (with your username)
- [ ] Set up email subscription and confirmed via email
- [ ] Created CPU utilization alarm: `USERNAME-High-CPU-Usage`
- [ ] Created status check alarm: `USERNAME-System-Status-Check-Failed`
- [ ] Created network alarm: `USERNAME-High-Network-Out`
- [ ] Configured all alarms with proper thresholds
- [ ] Tested alarm functionality by generating CPU load
- [ ] Received email notifications from triggered alarms

### Task 4: CloudWatch Logs Configuration
- [ ] Installed and configured CloudWatch agent
- [ ] Created log groups for Apache and application logs
- [ ] Generated log data for testing
- [ ] Explored CloudWatch Logs interface
- [ ] Created log metric filter for ERROR patterns
- [ ] Tested log filtering and search functionality
- [ ] Verified custom metrics publication

### Advanced Exercises (Optional)
- [ ] Used CloudWatch Insights for complex log queries
- [ ] Published custom metrics using AWS CLI
- [ ] Created EventBridge rule for EC2 state changes

### Cleanup
- [ ] Deleted all CloudWatch alarms
- [ ] Deleted custom dashboard
- [ ] Deleted SNS subscription and topic
- [ ] Deleted CloudWatch log groups
- [ ] Terminated EC2 instance
- [ ] Deleted custom security group
- [ ] Verified all resources cleaned up

## Notes

**Your Username:** ________________

**Resource Names (with your username):**
- EC2 Instance: ________________-monitoring-target
- Dashboard: ________________-monitoring-dashboard
- SNS Topic: ________________-cloudwatch-alerts
- Security Group: ________________-monitoring-sg

**Instance Details:**
- Instance ID: ________________
- Public IP: ________________
- Key Pair Used: ________________

**Alarm Names:**
- CPU Alarm: ________________-High-CPU-Usage
- Status Alarm: ________________-System-Status-Check-Failed
- Network Alarm: ________________-High-Network-Out

**Email for Notifications:** ________________

**Log Groups Created:**
- Apache Access: ________________-apache-access
- Apache Error: ________________-apache-error
- Application: ________________-application-logs

**Issues Encountered:**


**Solutions Applied:**


**Key Insights:**


**Alarm Test Results:**
- Email notification received: [ ] Yes [ ] No
- Time to trigger alarm: ________________
- Dashboard updates observed: [ ] Yes [ ] No

**Time Completed:** ________________

