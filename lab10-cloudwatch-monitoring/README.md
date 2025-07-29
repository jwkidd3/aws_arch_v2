# Lab 10: CloudWatch Monitoring & Alerts

**Duration:** 45 minutes  
**Objective:** Implement comprehensive CloudWatch monitoring, create custom dashboards, configure alarms, and set up automated notification systems for infrastructure monitoring and alerting.

## Prerequisites
- Completion of previous labs (Lab 1-9)
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)
- Running EC2 instances from previous labs

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Configure CloudWatch monitoring for various AWS services
- Create custom CloudWatch dashboards for centralized monitoring
- Set up CloudWatch alarms with automated notifications
- Implement custom metrics and log monitoring
- Configure SNS for alert notifications
- Understand CloudWatch Events and automated responses
- Analyze performance trends and troubleshoot using CloudWatch

---

## Task 1: CloudWatch Dashboard Creation (15 minutes)

### Step 1: Verify Existing Resources
1. **Check Running Resources:**
   - Navigate to **EC2 Dashboard**
   - Ensure you have at least one running instance from previous labs
   - If no instances are running, launch a t2.micro instance: `USERNAME-monitor-test` ⚠️ **Replace USERNAME with your assigned username**

2. **Generate Activity for Monitoring:**
   ```bash
   # SSH into your instance and run:
   sudo yum update -y
   sudo yum install -y stress htop
   
   # Generate some CPU activity
   stress --cpu 1 --timeout 60s
   ```

### Step 2: Create CloudWatch Dashboard
1. **Navigate to CloudWatch:**
   - In the AWS Management Console, search for "CloudWatch"
   - Click on **CloudWatch** to open the service

2. **Create New Dashboard:**
   - In the left navigation, click **Dashboards**
   - Click **Create dashboard**
   - **Dashboard name:** `USERNAME-monitoring-dashboard` ⚠️ **Replace USERNAME with your assigned username**
   - Click **Create dashboard**

3. **Add CPU Utilization Widget:**
   - Select **Line** widget type
   - **Metrics** → **EC2** → **Per-Instance Metrics**
   - Find your instance and select **CPUUtilization**
   - **Widget title:** "EC2 CPU Utilization"
   - Click **Create widget**

4. **Add Network I/O Widget:**
   - Click **Add widget** → **Line**
   - Select **EC2** → **Per-Instance Metrics**
   - For your instance, select both:
     - **NetworkIn**
     - **NetworkOut**
   - **Widget title:** "Network I/O"
   - Click **Create widget**

5. **Add Status Check Widget:**
   - Click **Add widget** → **Number**
   - Select **EC2** → **Per-Instance Metrics**
   - For your instance, select:
     - **StatusCheckFailed**
     - **StatusCheckFailed_Instance**
     - **StatusCheckFailed_System**
   - **Widget title:** "Status Checks"
   - Click **Create widget**

6. **Add Text Widget for Documentation:**
   - Click **Add widget** → **Text**
   - Add documentation about your dashboard:
   ```markdown
   # USERNAME Monitoring Dashboard
   
   **Instance:** USERNAME-monitor-test
   **Purpose:** Comprehensive infrastructure monitoring
   **Last Updated:** [Current Date]
   
   ## Widgets:
   - CPU Utilization: Real-time CPU usage
   - Network I/O: Inbound/outbound traffic
   - Status Checks: Instance and system health
   ```
   - Click **Create widget**

7. **Save Dashboard:**
   - Click **Save dashboard**

---

## Task 2: CloudWatch Alarms and SNS Configuration (20 minutes)

### Step 1: Create SNS Topic for Alerts
1. **Navigate to SNS:**
   - In AWS Console, search for "SNS"
   - Click **Simple Notification Service**

2. **Create Topic:**
   - Click **Create topic**
   - **Type:** Standard
   - **Name:** `USERNAME-monitoring-alerts` ⚠️ **Replace USERNAME with your assigned username**
   - **Display name:** `USERNAME Monitoring Alerts`
   - Click **Create topic**

3. **Create Email Subscription:**
   - In your topic, click **Create subscription**
   - **Protocol:** Email
   - **Endpoint:** Your email address
   - Click **Create subscription**
   - **Check your email** and click the confirmation link

### Step 2: Create CloudWatch Alarms
1. **Navigate Back to CloudWatch:**
   - Go to CloudWatch console
   - Click **Alarms** → **All alarms**

2. **Create CPU Utilization Alarm:**
   - Click **Create alarm**
   - **Select metric** → **EC2** → **Per-Instance Metrics**
   - Select your instance and **CPUUtilization**
   - Click **Select metric**
   
   **Configure Alarm:**
   - **Statistic:** Average
   - **Period:** 5 minutes
   - **Threshold type:** Static
   - **Condition:** Greater than **80**
   - Click **Next**
   
   **Configure Actions:**
   - **Alarm state trigger:** In alarm
   - **SNS topic:** Select `USERNAME-monitoring-alerts`
   - Click **Next**
   
   **Add Name and Description:**
   - **Alarm name:** `USERNAME-high-cpu-alarm` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** "Alert when CPU utilization exceeds 80%"
   - Click **Next** → **Create alarm**

3. **Create Status Check Alarm:**
   - Click **Create alarm**
   - **Select metric** → **EC2** → **Per-Instance Metrics**
   - Select your instance and **StatusCheckFailed**
   - Click **Select metric**
   
   **Configure Alarm:**
   - **Statistic:** Maximum
   - **Period:** 1 minute
   - **Threshold type:** Static
   - **Condition:** Greater than **0**
   - Click **Next**
   
   **Configure Actions:**
   - **SNS topic:** Select `USERNAME-monitoring-alerts`
   - Click **Next**
   
   **Add Name:**
   - **Alarm name:** `USERNAME-status-check-alarm` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** "Alert when instance status checks fail"
   - Click **Next** → **Create alarm**

4. **Create Network Traffic Alarm:**
   - Click **Create alarm**
   - **Select metric** → **EC2** → **Per-Instance Metrics**
   - Select your instance and **NetworkIn**
   - Click **Select metric**
   
   **Configure Alarm:**
   - **Statistic:** Sum
   - **Period:** 5 minutes
   - **Threshold type:** Static
   - **Condition:** Greater than **100000000** (100MB)
   - Click **Next**
   
   **Configure Actions:**
   - **SNS topic:** Select `USERNAME-monitoring-alerts`
   - Click **Next**
   
   **Add Name:**
   - **Alarm name:** `USERNAME-high-network-alarm` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** "Alert when network traffic is high"
   - Click **Next** → **Create alarm**

### Step 3: Test Alarm Functionality
1. **Generate High CPU Load:**
   - SSH into your EC2 instance
   - Run: `stress --cpu 2 --timeout 600s` (10 minutes of load)
   - Monitor the alarm in CloudWatch console
   - Wait 5-10 minutes for alarm to trigger

2. **Verify Email Notification:**
   - Check your email for alarm notifications
   - Verify alarm state changes from OK to ALARM

3. **Stop Load and Verify Recovery:**
   - Stop the stress test (Ctrl+C if needed)
   - Wait for alarm to return to OK state
   - Verify recovery email notification

---

## Task 3: CloudWatch Logs and Custom Metrics (10 minutes)

### Step 1: Custom Metrics (Optional Advanced Exercise)
1. **Install AWS CLI on Instance (if not present):**
   ```bash
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

2. **Send Custom Metrics:**
   ```bash
   # Send custom application metrics
   aws cloudwatch put-metric-data \
       --namespace "USERNAME/CustomApp" \
       --metric-data MetricName=UserLogins,Value=25,Unit=Count
   
   aws cloudwatch put-metric-data \
       --namespace "USERNAME/CustomApp" \
       --metric-data MetricName=ResponseTime,Value=150,Unit=Milliseconds
   ```

3. **View Custom Metrics:**
   - In CloudWatch console, go to **Metrics**
   - Look for **Custom Namespaces** → **USERNAME/CustomApp**
   - Add custom metrics to your dashboard

### Step 2: CloudWatch Logs (Optional)
1. **Install CloudWatch Agent (Advanced):**
   ```bash
   sudo yum install -y amazon-cloudwatch-agent
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
   ```

2. **Basic Log Monitoring:**
   - Create log groups in CloudWatch Logs
   - Configure log streams for application logs
   - Use CloudWatch Logs Insights for log analysis

---

## Advanced Exercises (Optional)

### Exercise 1: CloudWatch Events
1. **Create CloudWatch Event Rule:**
   - Navigate to CloudWatch → Events → Rules
   - Create rule for EC2 instance state changes
   - Configure SNS notification for instance termination

### Exercise 2: Multi-Service Dashboard
1. **Expand Dashboard:**
   - Add widgets for other services (S3, RDS if available)
   - Create service-specific views
   - Configure time ranges and refresh intervals

### Exercise 3: Cost Monitoring
1. **Set up Billing Alerts:**
   - Navigate to Billing Dashboard
   - Create CloudWatch billing alarms
   - Monitor AWS costs and usage

---

## Cleanup Instructions

**⚠️ Important:** Clean up resources to avoid charges

### Step 1: Clean Up Alarms and Notifications
1. **Delete CloudWatch Alarms:**
   - Go to CloudWatch → Alarms
   - Select all alarms with your username prefix
   - Actions → Delete
   - Confirm deletion

2. **Clean Up SNS:**
   - Go to SNS → Topics
   - Select your topic: `USERNAME-monitoring-alerts`
   - Delete topic
   - Confirm deletion

### Step 2: Clean Up Custom Metrics and Dashboards
1. **Delete Dashboard:**
   - Go to CloudWatch → Dashboards
   - Select your dashboard: `USERNAME-monitoring-dashboard`
   - Delete dashboard

2. **Custom Metrics:**
   - Custom metrics will automatically expire (no action needed)
   - Log groups can be deleted if created

### Step 3: Stop Test Instances
1. **Terminate Test Instances:**
   - If you created `USERNAME-monitor-test` instance for this lab
   - Go to EC2 → Instances
   - Terminate the test instance

---

## Troubleshooting

### Common Issues and Solutions

**Issue: Alarms not triggering**
- **Solution:** Check metric data is available, verify threshold values
- **Check:** Alarm configuration and SNS topic subscription

**Issue: Email notifications not received**
- **Solution:** Confirm SNS subscription via email
- **Check:** Spam folder, verify email address

**Issue: Dashboard widgets show no data**
- **Solution:** Verify metrics are being generated
- **Check:** Instance is running and generating activity

**Issue: Custom metrics not appearing**
- **Solution:** Check AWS CLI configuration and permissions
- **Verify:** Namespace and metric names are correct

**Issue: CloudWatch agent not working**
- **Solution:** Check IAM permissions for CloudWatch
- **Verify:** Agent configuration and service status

---

## Key Concepts Learned

1. **CloudWatch Monitoring:**
   - Understanding metrics, alarms, and dashboards
   - Configuring monitoring for various AWS services
   - Setting up proactive alerting systems

2. **SNS Integration:**
   - Creating notification topics and subscriptions
   - Integrating SNS with CloudWatch alarms
   - Managing alert distribution and escalation

3. **Custom Metrics and Logging:**
   - Publishing custom application metrics
   - Using CloudWatch Logs for centralized logging
   - Implementing log analysis with CloudWatch Insights

4. **Monitoring Strategy:**
   - Implementing proactive monitoring and alerting
   - Dashboard design for effective visualization
   - Alarm configuration with appropriate thresholds
   - Custom metrics for application-specific monitoring
   - Automation using CloudWatch for automated responses

## Summary

You have successfully:
- ✅ Created a comprehensive CloudWatch dashboard
- ✅ Configured CloudWatch alarms with email notifications
- ✅ Set up SNS for alert distribution
- ✅ Implemented custom metrics (optional)
- ✅ Tested alarm functionality and notifications
- ✅ Learned monitoring best practices

This lab provides the foundation for implementing robust monitoring and alerting in production AWS environments.

