# Lab 7: CloudWatch Monitoring & Alerts

**Duration:** 45 minutes  
**Objective:** Implement comprehensive CloudWatch monitoring, create custom dashboards, configure alarms with SNS notifications, and understand CloudWatch Logs for application monitoring.

## Prerequisites
- Completion of previous labs (VPC, EC2, RDS setup)
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Configure CloudWatch monitoring for EC2 instances and RDS databases
- Create custom CloudWatch dashboards for operational visibility
- Set up CloudWatch alarms with SNS notifications
- Implement CloudWatch Logs for application monitoring
- Understand CloudWatch Events for automated responses
- Configure custom metrics and log monitoring
- Troubleshoot using CloudWatch insights and analytics

---

## Task 1: Infrastructure Setup for Monitoring (10 minutes)

### Step 1: Launch EC2 Instance with Enhanced Monitoring
1. **Navigate to EC2:**
   - In the AWS Management Console, go to **EC2** service
   - Click **Instances** in the left navigation menu

2. **Launch Monitoring Target Instance:**
   - Click **Launch Instances**
   - **Name:** `USERNAME-monitoring-target` ⚠️ **Replace USERNAME with your assigned username**
   - **AMI:** Amazon Linux 2023 AMI
   - **Instance type:** t2.micro
   - **Key pair:** Use existing `USERNAME-keypair` or create new ⚠️ **Use your username**

3. **Advanced Configuration:**
   - **VPC:** Use existing VPC from previous labs (or default)
   - **Subnet:** Public subnet
   - **Auto-assign public IP:** Enable
   - **Security group:** Create new `USERNAME-monitoring-sg` ⚠️ **Replace USERNAME with your assigned username**
   - **Rules:**
     - SSH (22) from 0.0.0.0/0
     - HTTP (80) from 0.0.0.0/0
     - HTTPS (443) from 0.0.0.0/0
     - Custom TCP (8080) from 0.0.0.0/0

4. **CloudWatch Settings:**
   - **Detailed monitoring:** Enable (important for this lab)
   - **User data:** Add the monitoring setup script:

   ```bash
   #!/bin/bash
   # Enhanced monitoring setup script
   yum update -y
   yum install -y httpd amazon-cloudwatch-agent htop stress
   
   # Configure Apache
   systemctl start httpd
   systemctl enable httpd
   
   # Create load generation script
   cat > /home/ec2-user/generate_load.sh << 'SCRIPT'
   #!/bin/bash
   # Generate CPU load for testing
   stress --cpu 2 --timeout 300s &
   echo "CPU load generation started for 5 minutes"
   SCRIPT
   
   chmod +x /home/ec2-user/generate_load.sh
   
   # Create memory usage script
   cat > /home/ec2-user/memory_test.sh << 'SCRIPT'
   #!/bin/bash
   # Generate memory load for testing
   stress --vm 1 --vm-bytes 500M --timeout 300s &
   echo "Memory load generation started for 5 minutes"
   SCRIPT
   
   chmod +x /home/ec2-user/memory_test.sh
   
   # Create custom application log
   mkdir -p /var/log/myapp
   cat > /var/log/myapp/application.log << 'LOG'
   2024-01-01 10:00:01 INFO Application started successfully
   2024-01-01 10:00:02 INFO Database connection established
   2024-01-01 10:01:01 INFO Processing user request - ID: 12345
   2024-01-01 10:01:02 WARN High memory usage detected - 85%
   2024-01-01 10:02:01 ERROR Failed to connect to external API - timeout
   2024-01-01 10:02:02 INFO Retrying external API connection
   2024-01-01 10:03:01 INFO External API connection restored
   LOG
   
   chmod 644 /var/log/myapp/application.log
   
   # Create monitoring status page
   cat > /var/www/html/index.html << 'HTML'
   <!DOCTYPE html>
   <html>
   <head>
       <title>CloudWatch Monitoring Lab - USERNAME</title>
       <meta http-equiv="refresh" content="30">
       <style>
           body { font-family: Arial, sans-serif; margin: 40px; background: #f0f8ff; }
           .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
           .metric { background: #e7f3ff; padding: 15px; margin: 10px 0; border-radius: 5px; }
           .status { display: inline-block; width: 12px; height: 12px; border-radius: 50%; margin-right: 8px; }
           .healthy { background-color: #28a745; }
           .warning { background-color: #ffc107; }
           .critical { background-color: #dc3545; }
       </style>
   </head>
   <body>
       <div class="container">
           <h1>🖥️ CloudWatch Monitoring Dashboard</h1>
           <h2>Instance Owner: USERNAME</h2>
           <div class="metric">
               <h3><span class="status healthy"></span>System Status</h3>
               <p><strong>Instance ID:</strong> <span id="instance-id">Loading...</span></p>
               <p><strong>Uptime:</strong> <span id="uptime">Loading...</span></p>
               <p><strong>Load Average:</strong> <span id="load">Loading...</span></p>
           </div>
           <div class="metric">
               <h3><span class="status warning"></span>Resource Usage</h3>
               <p><strong>Memory:</strong> <span id="memory">Loading...</span></p>
               <p><strong>Disk:</strong> <span id="disk">Loading...</span></p>
           </div>
           <div class="metric">
               <h3><span class="status healthy"></span>Application Status</h3>
               <p><strong>Web Server:</strong> Apache HTTP Server</p>
               <p><strong>CloudWatch Agent:</strong> Installed</p>
               <p><strong>Custom Metrics:</strong> Enabled</p>
           </div>
           <p><small>Page auto-refreshes every 30 seconds | CloudWatch Lab</small></p>
       </div>
       
       <script>
           // Simulate dynamic content updates
           function updateMetrics() {
               document.getElementById('instance-id').textContent = 'i-' + Math.random().toString(36).substr(2, 9);
               document.getElementById('uptime').textContent = Math.floor(Math.random() * 24) + ' hours';
               document.getElementById('load').textContent = (Math.random() * 2).toFixed(2);
               document.getElementById('memory').textContent = Math.floor(Math.random() * 40 + 60) + '%';
               document.getElementById('disk').textContent = Math.floor(Math.random() * 20 + 70) + '%';
           }
           updateMetrics();
           setInterval(updateMetrics, 5000);
       </script>
   </body>
   </html>
HTML
   
   # Replace USERNAME placeholder
   sed -i "s/USERNAME/$(curl -s http://169.254.169.254/latest/meta-data/instance-id | cut -c3-)/g" /var/www/html/index.html
   
   # Log completion
   echo "Monitoring setup completed at $(date)" >> /var/log/cloud-init-output.log
   ```

5. **Launch the Instance:**
   - Review configuration
   - Click **Launch instance**

### Step 2: Verify Instance and Initial Monitoring
1. **Wait for Instance to Launch:**
   - Monitor instance state until "running"
   - Note the **Public IPv4 address**

2. **Test Web Interface:**
   - Open browser to: `http://YOUR_PUBLIC_IP`
   - Verify the monitoring dashboard displays

3. **Initial CloudWatch Check:**
   - Navigate to **CloudWatch** service
   - Go to **Metrics** → **All metrics**
   - Look for **EC2** metrics for your instance
   - Verify metrics are being collected

---

## Task 2: Create Custom CloudWatch Dashboard (12 minutes)

### Step 1: Create Comprehensive Dashboard
1. **Navigate to CloudWatch Dashboards:**
   - In CloudWatch console, click **Dashboards**
   - Click **Create dashboard**

2. **Configure Dashboard:**
   - **Dashboard name:** `USERNAME-monitoring-dashboard` ⚠️ **Replace USERNAME with your assigned username**
   - Click **Create dashboard**

### Step 2: Add EC2 Metrics Widgets
1. **Add CPU Utilization Widget:**
   - Click **Add widget**
   - Select **Line** chart
   - Click **Configure**
   - **Metrics tab:**
     - **Namespace:** AWS/EC2
     - **Metric name:** CPUUtilization
     - **Instance:** Select your instance
   - **Graphed metrics tab:**
     - **Period:** 1 minute
     - **Statistic:** Average
   - **Widget title:** `USERNAME CPU Utilization` ⚠️ **Use your username**
   - Click **Create widget**

2. **Add Network Metrics Widget:**
   - Click **Add widget**
   - Select **Number** widget
   - **Metrics:**
     - Add NetworkIn and NetworkOut for your instance
   - **Widget title:** `USERNAME Network Traffic` ⚠️ **Use your username**
   - Click **Create widget**

3. **Add Status Check Widget:**
   - Click **Add widget**
   - Select **Line** chart
   - **Metrics:**
     - StatusCheckFailed (both System and Instance)
   - **Widget title:** `USERNAME Status Checks` ⚠️ **Use your username**
   - Click **Create widget**

### Step 3: Add Custom Application Metrics
1. **Add Disk Usage Widget:**
   - Click **Add widget**
   - Select **Gauge** widget
   - **Metrics:**
     - AWS/EC2 → EBSVolumeReadOps and EBSVolumeWriteOps
   - **Widget title:** `USERNAME Disk Operations` ⚠️ **Use your username**
   - Click **Create widget**

2. **Save Dashboard:**
   - Click **Save dashboard**
   - Verify all widgets display data

---

## Task 3: Configure CloudWatch Alarms with SNS (15 minutes)

### Step 1: Create SNS Topic for Notifications
1. **Navigate to SNS:**
   - Go to **Simple Notification Service (SNS)**
   - Click **Topics** in left navigation

2. **Create Topic:**
   - Click **Create topic**
   - **Type:** Standard
   - **Name:** `USERNAME-cloudwatch-alerts` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** `CloudWatch alerts for USERNAME monitoring lab` ⚠️ **Use your username**
   - Click **Create topic**

3. **Create Subscription:**
   - Click **Create subscription**
   - **Protocol:** Email
   - **Endpoint:** Your email address (use a real email you can access)
   - Click **Create subscription**
   - **Check your email** and confirm the subscription

### Step 2: Create High CPU Utilization Alarm
1. **Navigate to CloudWatch Alarms:**
   - Go back to **CloudWatch**
   - Click **Alarms** → **All alarms**

2. **Create CPU Alarm:**
   - Click **Create alarm**
   - **Select metric:**
     - **Namespace:** AWS/EC2
     - **Metric name:** CPUUtilization
     - **Instance:** Select your instance
     - Click **Select metric**

3. **Configure Alarm Conditions:**
   - **Alarm name:** `USERNAME-High-CPU-Usage` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** `Alert when CPU exceeds 70% for USERNAME instance` ⚠️ **Use your username**
   - **Threshold type:** Static
   - **Condition:** Greater than 70
   - **Period:** 1 minute
   - **Datapoints to alarm:** 2 out of 2
   - **Missing data treatment:** Treat missing data as bad

4. **Configure Actions:**
   - **Alarm state trigger:** In alarm
   - **SNS topic:** Select `USERNAME-cloudwatch-alerts` ⚠️ **Use your username**
   - Click **Create alarm**

### Step 3: Create Additional Critical Alarms
1. **Create Status Check Alarm:**
   - Create new alarm for **StatusCheckFailed_System**
   - **Name:** `USERNAME-System-Status-Check-Failed` ⚠️ **Replace USERNAME with your assigned username**
   - **Threshold:** Greater than or equal to 1
   - **Period:** 1 minute
   - **SNS topic:** Same as above

2. **Create Network Alarm:**
   - Create new alarm for **NetworkOut**
   - **Name:** `USERNAME-High-Network-Out` ⚠️ **Replace USERNAME with your assigned username**
   - **Threshold:** Greater than 10000000 bytes (10MB)
   - **Period:** 5 minutes
   - **SNS topic:** Same as above

### Step 4: Test Alarm Functionality
1. **Connect to Instance:**
   - SSH to your instance or use EC2 Instance Connect

2. **Generate CPU Load:**
   ```bash
   # Execute the load generation script
   ./generate_load.sh
   
   # Monitor in real-time
   htop
   ```

3. **Monitor Alarms:**
   - Watch CloudWatch alarms transition from OK to ALARM
   - Check your email for alarm notifications
   - Observe dashboard updates

---

## Task 4: CloudWatch Logs Configuration (8 minutes)

### Step 1: Configure CloudWatch Agent
1. **Install and Configure Agent:**
   ```bash
   # Connect to your instance
   sudo yum install -y amazon-cloudwatch-agent
   
   # Create CloudWatch agent configuration
   sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null << 'CONFIG'
   {
       "logs": {
           "logs_collected": {
               "files": {
                   "collect_list": [
                       {
                           "file_path": "/var/log/httpd/access_log",
                           "log_group_name": "USERNAME-apache-access",
                           "log_stream_name": "{instance_id}/apache-access",
                           "timezone": "UTC"
                       },
                       {
                           "file_path": "/var/log/httpd/error_log",
                           "log_group_name": "USERNAME-apache-error",
                           "log_stream_name": "{instance_id}/apache-error",
                           "timezone": "UTC"
                       },
                       {
                           "file_path": "/var/log/myapp/application.log",
                           "log_group_name": "USERNAME-application-logs",
                           "log_stream_name": "{instance_id}/application",
                           "timezone": "UTC"
                       }
                   ]
               }
           }
       },
       "metrics": {
           "namespace": "USERNAME/CustomMetrics",
           "metrics_collected": {
               "mem": {
                   "measurement": ["mem_used_percent"]
               },
               "disk": {
                   "measurement": ["used_percent"],
                   "resources": ["*"]
               }
           }
       }
   }
CONFIG
   
   # Replace USERNAME in config
   sudo sed -i "s/USERNAME/$(whoami)/g" /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
   
   # Start CloudWatch agent
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
   ```

### Step 2: Generate Log Data
1. **Create Log Activity:**
   ```bash
   # Generate Apache access logs
   for i in {1..10}; do
       curl -s http://localhost/ > /dev/null
       sleep 1
   done
   
   # Add custom application logs
   echo "$(date) INFO User USERNAME logged in successfully" | sudo tee -a /var/log/myapp/application.log
   echo "$(date) WARN High memory usage detected - 90%" | sudo tee -a /var/log/myapp/application.log
   echo "$(date) ERROR Database connection timeout" | sudo tee -a /var/log/myapp/application.log
   ```

### Step 3: Explore CloudWatch Logs
1. **Navigate to CloudWatch Logs:**
   - Go to **CloudWatch** → **Logs** → **Log groups**
   - Look for your log groups (USERNAME-apache-access, etc.)

2. **Analyze Logs:**
   - Click on each log group
   - Explore log streams
   - Use **Filter events** to search for specific entries:
     - Filter pattern: `ERROR`
     - Filter pattern: `WARN`
     - Time range: Last 30 minutes

3. **Create Log Metric Filter:**
   - In your application log group, click **Create metric filter**
   - **Filter pattern:** `ERROR`
   - **Metric namespace:** `USERNAME/ApplicationMetrics` ⚠️ **Use your username**
   - **Metric name:** `ErrorCount`
   - **Metric value:** 1
   - Create alarm based on this custom metric

---

## Advanced Exercises (Optional)

### Exercise 1: CloudWatch Insights
Create complex log queries using CloudWatch Insights:

```sql
fields @timestamp, @message
| filter @message like /ERROR/
| stats count() by bin(5m)
```

### Exercise 2: Custom Metrics with AWS CLI
```bash
# Send custom metric to CloudWatch
aws cloudwatch put-metric-data \
    --namespace "USERNAME/CustomApp" \
    --metric-data MetricName=UserLogins,Value=5,Unit=Count
```

### Exercise 3: CloudWatch Events Rule
Create an EventBridge rule to respond to EC2 state changes:
- Rule name: `USERNAME-ec2-state-changes`
- Event pattern: EC2 Instance State-change Notification
- Target: SNS topic for notifications

---

## Cleanup Instructions

**⚠️ Important:** Clean up resources to avoid charges

### Step 1: Delete Alarms and Dashboards
1. **Delete CloudWatch Alarms:**
   - Go to **CloudWatch** → **Alarms**
   - Select all alarms with your username
   - **Actions** → **Delete**

2. **Delete Dashboard:**
   - Go to **Dashboards**
   - Select your dashboard
   - **Actions** → **Delete**

### Step 2: Clean Up SNS Resources
1. **Delete SNS Subscription:**
   - Go to **SNS** → **Subscriptions**
   - Select your subscription
   - **Actions** → **Delete**

2. **Delete SNS Topic:**
   - Go to **Topics**
   - Select your topic
   - **Delete**

### Step 3: Clean Up Log Groups
1. **Delete CloudWatch Log Groups:**
   - Go to **CloudWatch** → **Log groups**
   - Select log groups with your username
   - **Actions** → **Delete log group**

### Step 4: Terminate EC2 Resources
1. **Terminate Instance:**
   - Go to **EC2** → **Instances**
   - Select your monitoring instance
   - **Instance state** → **Terminate instance**

2. **Delete Security Group:**
   - Go to **Security Groups**
   - Select your monitoring security group
   - **Actions** → **Delete security group**

---

## Troubleshooting

### Common Issues and Solutions

**Issue: CloudWatch Agent not sending logs**
- **Solution:** Check IAM role has CloudWatchAgentServerPolicy
- **Verify:** `sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a query-config`

**Issue: Alarms not triggering**
- **Solution:** Verify metric data is being published
- **Check:** Alarm threshold and evaluation periods
- **Verify:** SNS topic subscription is confirmed

**Issue: Dashboard widgets showing no data**
- **Solution:** Check metric namespace and dimensions
- **Verify:** Time range and period settings
- **Check:** Instance is running and sending metrics

**Issue: Email notifications not received**
- **Solution:** Confirm SNS subscription via email
- **Check:** Spam folder for AWS notifications
- **Verify:** Email address is correct in subscription

---

## Key Concepts Learned

1. **CloudWatch Monitoring Architecture:**
   - Metrics collection and storage
   - Namespaces and dimensions
   - Standard vs detailed monitoring

2. **Dashboard Creation:**
   - Widget types and use cases
   - Metric visualization options
   - Dashboard sharing and permissions

3. **Alarm Configuration:**
   - Threshold types and conditions
   - Evaluation periods and datapoints
   - Alarm states and actions

4. **SNS Integration:**
   - Topic creation and management
   - Subscription protocols
   - Message delivery patterns

5. **CloudWatch Logs:**
   - Log group and stream organization
   - Agent configuration and management
   - Log filtering and analysis

6. **Custom Metrics:**
   - Publishing application metrics
   - Namespace and dimension design
   - Cost considerations

---

## Validation Checklist

- [ ] Successfully launched EC2 instance with detailed monitoring
- [ ] Created comprehensive CloudWatch dashboard with multiple widgets
- [ ] Configured SNS topic and email subscription
- [ ] Set up CloudWatch alarms with proper thresholds
- [ ] Tested alarm functionality with load generation
- [ ] Configured CloudWatch Logs agent successfully
- [ ] Created log groups and streams for application monitoring
- [ ] Implemented log metric filters and custom metrics
- [ ] Received email notifications from triggered alarms
- [ ] Explored CloudWatch Logs Insights for log analysis
- [ ] Cleaned up all resources properly

---

## Next Steps

- **Lab 8:** Application Load Balancer Setup
- **Advanced Topics:** CloudWatch Container Insights, X-Ray integration
- **Real-world Applications:** Multi-tier application monitoring, cost optimization

---

**Lab Duration:** 45 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Basic AWS knowledge, previous lab completion

