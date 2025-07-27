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

2. **Generate Some Activity:**
   - Connect to your EC2 instance via EC2 Instance Connect
   - Run some CPU and memory intensive commands to generate metrics:
   ```bash
   # Generate CPU load
   stress --cpu 1 --timeout 300s &
   
   # If stress is not available, use alternative
   yes > /dev/null &
   sleep 60
   kill %1
   
   # Generate some disk I/O
   dd if=/dev/zero of=/tmp/testfile bs=1M count=100
   rm /tmp/testfile
   
   # Check system resources
   top
   ```

### Step 2: Create Custom CloudWatch Dashboard
1. **Navigate to CloudWatch:**
   - In AWS Management Console, search for **CloudWatch**
   - Click on **CloudWatch** to open the dashboard

2. **Create New Dashboard:**
   - In the left navigation, click **Dashboards**
   - Click **Create dashboard**
   - **Dashboard name:** `USERNAME-monitoring-dashboard` ⚠️ **Replace USERNAME with your assigned username**
   - Click **Create dashboard**

3. **Add EC2 CPU Utilization Widget:**
   - Click **Add widget**
   - Select **Line** graph type
   - Click **Configure**
   - **Data source:** Metrics
   - **Metrics tab:**
     - Browse metrics → **EC2** → **Per-Instance Metrics**
     - Find your instance and select **CPUUtilization**
     - Click **Create widget**
   - **Widget title:** `USERNAME EC2 CPU Utilization` ⚠️ **Replace USERNAME with your assigned username**

4. **Add Memory and Network Widgets:**
   - Click **Add widget** again
   - Add **NetworkIn** and **NetworkOut** metrics for your instance
   - Create separate widgets for different metric types
   - Organize widgets in a logical layout

5. **Add Number Widget for Instance Status:**
   - Click **Add widget**
   - Select **Number** widget type
   - Add **StatusCheckFailed** metric
   - Configure to show current status

6. **Save Dashboard:**
   - Click **Save dashboard**
   - Your dashboard should now display multiple monitoring widgets

### Step 3: Enhanced Dashboard with Custom Metrics
1. **Add CloudWatch Logs Insights Widget:**
   - Click **Add widget**
   - Select **Logs table** widget
   - Configure to show recent log entries (if available)

2. **Add Text Widget for Documentation:**
   - Click **Add widget**
   - Select **Text** widget
   - Add documentation about your monitoring setup:
   ```
   ## USERNAME Monitoring Dashboard
   
   **Purpose:** Monitor EC2 instance performance and health
   **Owner:** USERNAME
   **Created:** [Current Date]
   
   **Widgets:**
   - CPU Utilization: Monitor processor usage
   - Network I/O: Track network traffic
   - Status Checks: Instance health monitoring
   
   **Alarm Thresholds:**
   - CPU > 80% for 5 minutes
   - Status check failures
   ```

---

## Task 2: CloudWatch Alarms and SNS Configuration (20 minutes)

### Step 1: Create SNS Topic for Notifications
1. **Navigate to SNS:**
   - Search for **SNS** in the AWS Management Console
   - Click on **Simple Notification Service**

2. **Create SNS Topic:**
   - Click **Topics** in left navigation
   - Click **Create topic**
   - **Type:** Standard
   - **Name:** `USERNAME-monitoring-alerts` ⚠️ **Replace USERNAME with your assigned username**
   - **Display name:** `USERNAME Monitoring Alerts` ⚠️ **Replace USERNAME with your assigned username**
   - Click **Create topic**

3. **Create Email Subscription:**
   - Click on your newly created topic
   - Click **Create subscription**
   - **Protocol:** Email
   - **Endpoint:** Enter a valid email address you can access
   - Click **Create subscription**
   - **Important:** Check your email and confirm the subscription

### Step 2: Create CloudWatch Alarms
1. **Return to CloudWatch:**
   - Navigate back to **CloudWatch** service
   - Click **Alarms** in left navigation
   - Click **Create alarm**

2. **Configure CPU Utilization Alarm:**
   - Click **Select metric**
   - **EC2** → **Per-Instance Metrics**
   - Select your instance's **CPUUtilization** metric
   - Click **Select metric**

3. **Define Alarm Conditions:**
   - **Statistic:** Average
   - **Period:** 5 minutes
   - **Threshold type:** Static
   - **Whenever CPUUtilization is:** Greater than 80
   - **Additional configuration:**
     - **Datapoints to alarm:** 2 out of 3
     - **Missing data treatment:** Treat missing data as not breaching

4. **Configure Actions:**
   - **Alarm state trigger:** In alarm
   - **Select an SNS topic:** Use existing topic
   - **SNS topic:** Select your `USERNAME-monitoring-alerts` topic
   - **Auto Scaling action:** None (for now)
   - **EC2 action:** None (for now)

5. **Add Alarm Details:**
   - **Alarm name:** `USERNAME-high-cpu-alarm` ⚠️ **Replace USERNAME with your assigned username**
   - **Alarm description:** `Alert when USERNAME instance CPU exceeds 80%` ⚠️ **Replace USERNAME with your assigned username**
   - Click **Create alarm**

### Step 3: Create Additional Alarms
1. **Status Check Alarm:**
   - Create another alarm for **StatusCheckFailed_System**
   - **Threshold:** Greater than or equal to 1
   - **Period:** 1 minute
   - **Alarm name:** `USERNAME-status-check-alarm` ⚠️ **Replace USERNAME with your assigned username**

2. **Network Traffic Alarm:**
   - Create alarm for **NetworkOut** 
   - **Threshold:** Greater than 1000000 bytes (1MB)
   - **Period:** 5 minutes
   - **Alarm name:** `USERNAME-high-network-alarm` ⚠️ **Replace USERNAME with your assigned username**

### Step 4: Test Alarm Functionality
1. **Generate High CPU Load:**
   - Connect to your EC2 instance
   - Run CPU-intensive command:
   ```bash
   # Generate sustained CPU load
   stress --cpu 2 --timeout 600s
   
   # Alternative if stress not available
   yes > /dev/null &
   yes > /dev/null &
   # Let it run for 10-15 minutes to trigger alarm
   ```

2. **Monitor Alarm States:**
   - Return to CloudWatch Alarms
   - Refresh the page periodically
   - Watch for alarm state changes: OK → ALARM
   - Check your email for alarm notifications

3. **Stop High Load:**
   ```bash
   # Stop the stress test
   pkill stress
   # or kill the yes processes
   pkill yes
   ```

---

## Task 3: CloudWatch Logs and Custom Metrics (10 minutes)

### Step 1: Install CloudWatch Agent (Optional - if time permits)
1. **Install CloudWatch Agent:**
   ```bash
   # Download and install CloudWatch agent
   wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
   sudo rpm -U ./amazon-cloudwatch-agent.rpm
   ```

2. **Basic Configuration:**
   ```bash
   # Create basic config (simplified for lab)
   sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null << 'JSON'
   {
       "metrics": {
           "namespace": "USERNAME/CustomMetrics",
           "metrics_collected": {
               "mem": {
                   "measurement": ["mem_used_percent"]
               },
               "disk": {
                   "measurement": ["used_percent"],
                   "metrics_collection_interval": 300,
                   "resources": ["*"]
               }
           }
       },
       "logs": {
           "logs_collected": {
               "files": {
                   "collect_list": [
                       {
                           "file_path": "/var/log/messages",
                           "log_group_name": "USERNAME-system-logs",
                           "log_stream_name": "{instance_id}"
                       }
                   ]
               }
           }
       }
   }
JSON
   ```

### Step 2: Custom Metrics via CLI
1. **Send Custom Metrics:**
   ```bash
   # Send custom metric data
   aws cloudwatch put-metric-data \
       --namespace "USERNAME/Application" \
       --metric-data MetricName=CustomTestMetric,Value=100,Unit=Count
   
   # Send custom metric with dimensions
   aws cloudwatch put-metric-data \
       --namespace "USERNAME/Application" \
       --metric-data MetricName=UserActivity,Value=25,Unit=Count,Dimensions=Action=Login
   ```

2. **Verify Custom Metrics:**
   - Go to CloudWatch → Metrics
   - Browse metrics → Custom namespaces
   - Find your custom namespace: `USERNAME/Application`
   - Add these metrics to your dashboard

### Step 3: CloudWatch Insights (if Log Groups exist)
1. **Use CloudWatch Logs Insights:**
   - Navigate to CloudWatch → Logs → Insights
   - If you have log groups, try these sample queries:
   ```
   fields @timestamp, @message
   | filter @message like /ERROR/
   | sort @timestamp desc
   | limit 20
   ```

   ```
   stats count() by bin(5m)
   ```

---

## Advanced Exercises (Optional)

### Exercise 1: Automated Responses with CloudWatch Events
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

4. **Operational Excellence:**
   - Implementing monitoring best practices
   - Creating actionable alerts and dashboards
   - Building automated response systems

5. **Cost and Performance Optimization:**
   - Monitoring resource utilization trends
   - Setting up cost alerts and budgets
   - Identifying optimization opportunities

---

## Validation Checklist

- [ ] Created custom CloudWatch dashboard with multiple widgets
- [ ] Configured SNS topic with email subscription
- [ ] Set up CloudWatch alarms for CPU, status, and network metrics
- [ ] Successfully tested alarm triggering and notifications
- [ ] Added custom metrics to monitoring setup
- [ ] Understood CloudWatch Logs and Insights functionality
- [ ] Implemented proper cleanup of all resources

---

## Next Steps

- **Lab 11:** Lambda Functions & API Gateway
- **Advanced Topics:** CloudWatch Events, automated remediation, cross-service monitoring
- **Real-world Applications:** Enterprise monitoring strategies, compliance reporting

---

**Lab Duration:** 45 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Basic understanding of AWS services, completed Labs 1-9

