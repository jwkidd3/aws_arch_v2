# Lab 6: CloudWatch Monitoring
## Implement Comprehensive Monitoring

**Duration:** 45 minutes  
**Prerequisites:** Have at least one running EC2 instance (from previous labs)

### Learning Objectives
By the end of this lab, you will be able to:
- Configure CloudWatch Agent on EC2 instances for detailed monitoring
- Create custom CloudWatch metrics and alarms
- Set up log aggregation and centralized monitoring
- Build monitoring dashboards for infrastructure visibility
- Implement automated alerting and notification systems
- Understand CloudWatch pricing and optimization strategies
- Use CloudWatch Insights for log analysis

### Architecture Overview
You will implement comprehensive monitoring for your AWS infrastructure using CloudWatch metrics, logs, and alarms. This includes installing the CloudWatch Agent, creating custom dashboards, setting up automated alerts, and configuring log aggregation for centralized monitoring.

### Part 1: Prepare Your Environment

#### Step 1: Launch Monitoring Instance (if needed)
1. If you don't have a running EC2 instance, launch one:
   - **AMI:** Amazon Linux 2023
   - **Instance Type:** t2.micro
   - **Security Group:** Allow SSH (port 22) and HTTP (port 80)
   - **Key Pair:** Select or create a key pair
   - **Name:** MonitoringTest

#### Step 2: Create IAM Role for CloudWatch Agent
1. Navigate to **IAM** service
2. Click **Roles** → **Create role**
3. **Trusted entity type:** AWS service
4. **Service:** EC2
5. **Permissions policies:** Add these policies:
   - `CloudWatchAgentServerPolicy`
   - `AmazonSSMManagedInstanceCore`
6. **Role name:** `CloudWatch-Agent-Role`
7. Click **Create role**

#### Step 3: Attach IAM Role to Instance
1. Navigate to **EC2** → **Instances**
2. Select your instance
3. **Actions** → **Security** → **Modify IAM role**
4. **IAM role:** Select `CloudWatch-Agent-Role`
5. Click **Update IAM role**

### Part 2: Install and Configure CloudWatch Agent

#### Step 1: Connect to Your Instance
1. Connect to your EC2 instance using **EC2 Instance Connect**
2. Update the system:
   ```bash
   sudo yum update -y
   ```

#### Step 2: Install CloudWatch Agent
1. Download and install the CloudWatch Agent:
   ```bash
   wget https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
   sudo rpm -U amazon-cloudwatch-agent.rpm
   ```

#### Step 3: Install Additional Monitoring Tools
1. Install system monitoring utilities:
   ```bash
   sudo yum install -y htop stress-ng
   ```

2. Install Apache web server for log monitoring:
   ```bash
   sudo yum install -y httpd
   sudo systemctl start httpd
   sudo systemctl enable httpd
   ```

#### Step 4: Create CloudWatch Agent Configuration
1. Create the agent configuration file:
   ```bash
   sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
   
   cat << 'EOF' | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
   {
       "agent": {
           "metrics_collection_interval": 60,
           "run_as_user": "cwagent"
       },
       "metrics": {
           "namespace": "CWAgent",
           "metrics_collected": {
               "cpu": {
                   "measurement": [
                       "cpu_usage_idle",
                       "cpu_usage_iowait",
                       "cpu_usage_user",
                       "cpu_usage_system"
                   ],
                   "metrics_collection_interval": 60,
                   "totalcpu": false
               },
               "disk": {
                   "measurement": [
                       "used_percent",
                       "free",
                       "used",
                       "total"
                   ],
                   "metrics_collection_interval": 60,
                   "resources": [
                       "*"
                   ]
               },
               "diskio": {
                   "measurement": [
                       "io_time",
                       "read_bytes",
                       "write_bytes",
                       "reads",
                       "writes"
                   ],
                   "metrics_collection_interval": 60,
                   "resources": [
                       "*"
                   ]
               },
               "mem": {
                   "measurement": [
                       "mem_used_percent",
                       "mem_available_percent",
                       "mem_used",
                       "mem_available"
                   ],
                   "metrics_collection_interval": 60
               },
               "netstat": {
                   "measurement": [
                       "tcp_established",
                       "tcp_time_wait"
                   ],
                   "metrics_collection_interval": 60
               },
               "swap": {
                   "measurement": [
                       "swap_used_percent",
                       "swap_free",
                       "swap_used"
                   ],
                   "metrics_collection_interval": 60
               }
           }
       },
       "logs": {
           "logs_collected": {
               "files": {
                   "collect_list": [
                       {
                           "file_path": "/var/log/messages",
                           "log_group_name": "/aws/ec2/system",
                           "log_stream_name": "{instance_id}/messages",
                           "timezone": "UTC"
                       },
                       {
                           "file_path": "/var/log/httpd/access_log",
                           "log_group_name": "/aws/ec2/apache",
                           "log_stream_name": "{instance_id}/access",
                           "timezone": "UTC"
                       },
                       {
                           "file_path": "/var/log/httpd/error_log",
                           "log_group_name": "/aws/ec2/apache",
                           "log_stream_name": "{instance_id}/error",
                           "timezone": "UTC"
                       }
                   ]
               }
           }
       }
   }
   EOF
   ```

#### Step 5: Start CloudWatch Agent
1. Start the CloudWatch Agent:
   ```bash
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
       -a fetch-config \
       -m ec2 \
       -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
       -s
   ```

2. Verify the agent is running:
   ```bash
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
       -m ec2 \
       -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
       -a query
   ```

### Part 3: Create Custom Metrics

#### Step 1: Generate Custom Application Metrics
1. Create a script to publish custom metrics:
   ```bash
   cat << 'EOF' > custom-metrics.sh
#!/bin/bash

# --- Get instance metadata using IMDSv2 ---
# First, request a session token
# X-aws-ec2-metadata-token-ttl-seconds: 21600 sets the token's time-to-live to 6 hours
# --noproxy ensures we bypass any proxy for the metadata service IP
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" --noproxy "169.254.169.254")

# Basic validation for TOKEN
if [ -z "$TOKEN" ] || [[ "$TOKEN" == *"<"* ]] || [[ "$TOKEN" == *"?"* ]]; then
    echo "ERROR: Failed to retrieve valid IMDSv2 TOKEN." >&2
    echo "       Raw curl output for token request: '$TOKEN'" >&2
    exit 1
fi

# Then, use the token to get the instance ID
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id --noproxy "169.254.169.254")

# Basic validation for INSTANCE_ID
if [ -z "$INSTANCE_ID" ] || [[ "$INSTANCE_ID" == *"<"* ]] || [[ "$INSTANCE_ID" == *"?"* ]]; then
    echo "ERROR: Failed to retrieve valid INSTANCE_ID from metadata service using IMDSv2 token." >&2
    echo "       Raw curl output for instance-id request: '$INSTANCE_ID'" >&2
    exit 1
fi

# Get system metrics
LOAD_AVG=$(uptime | awk '{print $(NF-2)}' | sed 's/,//')
MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.2f", $3/$2 * 100.0}')
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

# Get custom application metrics
ACTIVE_CONNECTIONS=$(netstat -an | grep :80 | grep ESTABLISHED | wc -l)
PROCESS_COUNT=$(ps aux | tail -n +2 | wc -l) # Exclude header from ps aux count

# Construct the MetricData JSON
# We use printf to create the JSON string for each metric and then join them
# JSON requires values to be quoted, even numbers, when part of the string payload.
METRIC_DATA_JSON="[
    {
        \"MetricName\": \"LoadAverage\",
        \"Value\": $LOAD_AVG,
        \"Unit\": \"None\",
        \"Dimensions\": [
            {
                \"Name\": \"InstanceId\",
                \"Value\": \"$INSTANCE_ID\"
            }
        ]
    },
    {
        \"MetricName\": \"MemoryUsagePercent\",
        \"Value\": $MEMORY_USAGE,
        \"Unit\": \"Percent\",
        \"Dimensions\": [
            {
                \"Name\": \"InstanceId\",
                \"Value\": \"$INSTANCE_ID\"
            }
        ]
    },
    {
        \"MetricName\": \"DiskUsagePercent\",
        \"Value\": $DISK_USAGE,
        \"Unit\": \"Percent\",
        \"Dimensions\": [
            {
                \"Name\": \"InstanceId\",
                \"Value\": \"$INSTANCE_ID\"
            }
        ]
    },
    {
        \"MetricName\": \"ActiveConnections\",
        \"Value\": $ACTIVE_CONNECTIONS,
        \"Unit\": \"Count\",
        \"Dimensions\": [
            {
                \"Name\": \"InstanceId\",
                \"Value\": \"$INSTANCE_ID\"
            }
        ]
    },
    {
        \"MetricName\": \"ProcessCount\",
        \"Value\": $PROCESS_COUNT,
        \"Unit\": \"Count\",
        \"Dimensions\": [
            {
                \"Name\": \"InstanceId\",
                \"Value\": \"$INSTANCE_ID\"
            }
        ]
    }
]"

# Publish custom metrics to CloudWatch using the constructed JSON
aws cloudwatch put-metric-data \
    --namespace "Custom/Application" \
    --metric-data "$METRIC_DATA_JSON"

echo "Custom metrics published at $(date)"
EOF

chmod +x custom-metrics.sh
   ```

2. Run the script to publish metrics:
   ```bash
   ./custom-metrics.sh
   ```

3. Set up a cron job to run every 5 minutes:
   ```bash
   (crontab -l 2>/dev/null; echo "*/5 * * * * /home/ec2-user/custom-metrics.sh >> /var/log/custom-metrics.log 2>&1") | crontab -
   ```

### Part 4: Create CloudWatch Dashboard

#### Step 1: Navigate to CloudWatch Console
1. Open **CloudWatch** service in AWS Console
2. Wait 5-10 minutes for metrics to appear

#### Step 2: Create Custom Dashboard
1. Click **Dashboards** in the left navigation
2. Click **Create dashboard**
3. **Dashboard name:** `Infrastructure-Monitoring`
4. Choose widget type: **Line graph**

#### Step 3: Add EC2 Instance Metrics
1. **Metrics** tab → **EC2** → **Per-Instance Metrics**
2. Find your instance and select:
   - `CPUUtilization`
   - `NetworkIn`
   - `NetworkOut`
3. Click **Create widget**

#### Step 4: Add CloudWatch Agent Metrics
1. Click **Add widget** → **Line graph**
2. **Metrics** tab → **CWAgent** → **InstanceId**
3. Select your instance and add:
   - `mem_used_percent`
   - `disk_used_percent`
4. Click **Create widget**

#### Step 5: Add Custom Application Metrics
1. Click **Add widget** → **Number**
2. **Metrics** tab → **Custom/Application** → **InstanceId**
3. Select:
   - `ActiveConnections`
   - `ProcessCount`
   - `LoadAverage`
4. Click **Create widget**

#### Step 6: Add Log Insights Widget
1. Click **Add widget** → **Logs table**
2. **Log groups:** Select `/aws/ec2/apache`
3. **Query:**
   ```
   fields @timestamp, @message
   | filter @message like /GET/
   | stats count() by bin(5m)
   | sort @timestamp desc
   ```
4. Click **Create widget**

#### Step 7: Save Dashboard
1. Click **Save dashboard**
2. Arrange widgets as desired

### Part 5: Create CloudWatch Alarms

#### Step 1: Create CPU Utilization Alarm
1. Navigate to **CloudWatch** → **Alarms** → **All alarms**
2. Click **Create alarm**
3. **Specify metric:**
   - **Namespace:** AWS/EC2
   - **Metric name:** CPUUtilization
   - **Instance:** Select your instance
   - Click **Select metric**
4. **Conditions:**
   - **Threshold type:** Static
   - **Condition:** Greater than
   - **Threshold value:** 80
5. **Additional configuration:**
   - **Datapoints to alarm:** 2 out of 2
   - **Period:** 5 minutes
6. Click **Next**

#### Step 2: Configure Alarm Actions
1. **Notification:**
   - **Alarm state trigger:** In alarm
   - **SNS topic:** Create new topic
   - **Topic name:** `infrastructure-alerts`
   - **Email endpoints:** Enter your email address
2. Click **Create topic**
3. Click **Next**

#### Step 3: Complete Alarm Setup
1. **Alarm name:** `High-CPU-Utilization`
2. **Alarm description:** `Alert when CPU utilization exceeds 80%`
3. Click **Next** → **Create alarm**

#### Step 4: Create Memory Usage Alarm
1. Click **Create alarm**
2. **Specify metric:**
   - **Namespace:** CWAgent
   - **Metric name:** mem_used_percent
   - **InstanceId:** Select your instance
3. **Conditions:**
   - **Threshold:** Greater than 85
4. **Actions:** Use existing SNS topic `infrastructure-alerts`
5. **Name:** `High-Memory-Usage`
6. Click **Create alarm**

#### Step 5: Create Disk Space Alarm
1. Create another alarm for disk usage:
   - **Metric:** `disk_used_percent`
   - **Threshold:** Greater than 90
   - **Name:** `High-Disk-Usage`

#### Step 6: Confirm SNS Subscription
1. Check your email for SNS subscription confirmation
2. Click the confirmation link

### Part 6: Test Monitoring and Alerting

#### Step 1: Generate CPU Load
1. Connect to your EC2 instance
2. Generate high CPU load:
   ```bash
   stress-ng --cpu 2 --timeout 600s
   ```

#### Step 2: Monitor Real-Time Metrics
1. Go to your CloudWatch dashboard
2. Watch the CPU utilization increase
3. Refresh the dashboard to see real-time updates

#### Step 3: Verify Alarm Triggers
1. Navigate to **CloudWatch** → **Alarms**
2. Watch the CPU alarm change from "OK" to "In alarm"
3. Check your email for alarm notification

#### Step 4: Generate Application Load
1. Create some web traffic:
   ```bash
   # In another terminal session
   for i in {1..100}; do
       curl -s http://localhost/ > /dev/null
       sleep 1
   done
   ```

2. Check Apache logs:
   ```bash
   sudo tail -f /var/log/httpd/access_log
   ```

### Part 7: Log Analysis with CloudWatch Insights

#### Step 1: Access CloudWatch Logs
1. Navigate to **CloudWatch** → **Logs** → **Log groups**
2. Find and click `/aws/ec2/apache`
3. Click on a log stream to view entries

#### Step 2: Use CloudWatch Insights
1. Click **CloudWatch Insights** in the left navigation
2. **Select log group(s):** `/aws/ec2/apache`
3. Run sample queries:

   **Query 1: Top IP addresses**
   ```
   fields @timestamp, @message
   | filter @message like /GET/
   | parse @message /^(?<ip>\S+)/
   | stats count() as requests by ip
   | sort requests desc
   | limit 10
   ```

   **Query 2: HTTP status codes**
   ```
   fields @timestamp, @message
   | filter @message like /GET/
   | parse @message /\s(?<status>\d{3})\s/
   | stats count() as requests by status
   | sort requests desc
   ```

   **Query 3: Request timeline**
   ```
   fields @timestamp, @message
   | filter @message like /GET/
   | stats count() as requests by bin(5m)
   | sort @timestamp desc
   ```

4. Click **Run query** for each query

### Part 8: Create Composite Alarms

#### Step 1: Create Composite Alarm
1. Navigate to **CloudWatch** → **Alarms** → **All alarms**
2. Click **Create alarm** → **Composite alarm**
3. **Alarm rule:**
   ```
   (ALARM("High-CPU-Utilization") OR ALARM("High-Memory-Usage")) AND ALARM("High-Disk-Usage")
   ```
4. **Actions:** Use existing SNS topic
5. **Name:** `Critical-System-Alert`
6. **Description:** `Multiple system resources under stress`
7. Click **Create alarm**

### Part 9: Set Up Log Retention and Costs

#### Step 1: Configure Log Retention
1. Navigate to **CloudWatch** → **Logs** → **Log groups**
2. Select `/aws/ec2/system`
3. **Actions** → **Edit retention setting**
4. **Retention:** 7 days
5. Repeat for other log groups

#### Step 2: Review CloudWatch Costs
1. Navigate to **CloudWatch** → **Usage**
2. Review:
   - **Metrics:** Number of custom metrics
   - **Logs:** Data ingested and stored
   - **Alarms:** Number of alarms configured
   - **API requests:** CloudWatch API usage

### Part 10: Advanced Monitoring Features

#### Step 1: Enable Detailed Monitoring
1. Navigate to **EC2** → **Instances**
2. Select your instance
3. **Actions** → **Monitor and troubleshoot** → **Manage detailed monitoring**
4. **Enable** detailed monitoring
5. Note: This increases monitoring frequency from 5 minutes to 1 minute

#### Step 2: Create Anomaly Detection
1. Navigate to **CloudWatch** → **Anomaly detection**
2. Click **Create anomaly detector**
3. **Select metric:**
   - **Namespace:** AWS/EC2
   - **Metric:** CPUUtilization
   - **Instance:** Your instance
4. **Anomaly detection model:** CloudWatch will automatically train
5. Click **Create anomaly detector**

#### Step 3: Set Up Metric Filters
1. Navigate to **CloudWatch** → **Logs** → **Log groups**
2. Select `/aws/ec2/apache`
3. **Metric filters** tab → **Create metric filter**
4. **Filter pattern:** `[ip, timestamp, request, status_code="404", size]`
5. **Test pattern** with sample log data
6. **Metric details:**
   - **Metric namespace:** `Apache/Errors`
   - **Metric name:** `404Errors`
   - **Metric value:** 1
7. Click **Create metric filter**

### Part 11: Export and Backup

#### Step 1: Export Dashboard
1. Go to your dashboard
2. **Actions** → **View/edit source**
3. Copy the JSON configuration
4. Save to a file for backup/replication

#### Step 2: Export Metrics Data
1. Use AWS CLI to export metrics:
   ```bash
   aws cloudwatch get-metric-statistics \
       --namespace AWS/EC2 \
       --metric-name CPUUtilization \
       --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
       --start-time 2023-01-01T00:00:00Z \
       --end-time 2023-01-02T00:00:00Z \
       --period 3600 \
       --statistics Average
   ```

### Part 12: Cleanup Resources

⚠️ **Important:** Clean up resources to avoid charges

#### Step 1: Stop CloudWatch Agent
1. On your EC2 instance:
   ```bash
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
       -m ec2 \
       -a stop
   ```

#### Step 2: Remove Custom Metrics Cron Job
1. Remove the cron job:
   ```bash
   crontab -r
   ```

#### Step 3: Delete CloudWatch Resources
1. **Delete Alarms:**
   - Navigate to **CloudWatch** → **Alarms**
   - Select all alarms and delete
2. **Delete Dashboard:**
   - Navigate to **Dashboards**
   - Select and delete your dashboard
3. **Delete Log Groups:**
   - Navigate to **Log groups**
   - Delete custom log groups (keep default ones)
4. **Delete SNS Topic:**
   - Navigate to **SNS** → **Topics**
   - Delete `infrastructure-alerts`

#### Step 4: Terminate EC2 Instance (Optional)
1. If you created a test instance, terminate it
2. Remove the IAM role if no longer needed

### Key Concepts Learned

**CloudWatch Metrics:**
- Default EC2 metrics vs. detailed monitoring
- Custom metrics with dimensions and namespaces
- CloudWatch Agent for system-level metrics
- Metric retention and aggregation

**CloudWatch Logs:**
- Centralized log collection and storage
- Log groups and log streams organization
- CloudWatch Insights for log analysis
- Metric filters for extracting metrics from logs

**CloudWatch Alarms:**
- Static and anomaly detection alarms
- Composite alarms for complex conditions
- SNS integration for notifications
- Alarm states and actions

**Monitoring Best Practices:**
- Appropriate metric collection intervals
- Cost optimization through retention policies
- Dashboard design for operational visibility
- Alerting strategies to reduce noise

### Troubleshooting Tips

**CloudWatch Agent not sending metrics:**
- Check IAM role has correct permissions
- Verify agent configuration file syntax
- Review agent logs: `/opt/aws/amazon-cloudwatch-agent/logs/`
- Ensure instance has internet connectivity

**Custom metrics not appearing:**
- Check AWS CLI credentials and permissions
- Verify metric namespace and dimensions
- Wait up to 15 minutes for first appearance
- Check for API throttling errors

**Alarms not triggering:**
- Verify metric data is being published
- Check alarm conditions and thresholds
- Ensure SNS topic and subscription are correct
- Review alarm history for troubleshooting

**High CloudWatch costs:**
- Review metric retention periods
- Optimize log retention settings
- Reduce custom metric frequency
- Use metric filters instead of custom metrics where possible

### Next Steps
This monitoring foundation prepares you for:
- Application Performance Monitoring (APM)
- Distributed tracing with X-Ray
- Container monitoring with ECS/EKS
- Serverless monitoring with Lambda
- Security monitoring and compliance
- Infrastructure as Code monitoring setup

You now have comprehensive monitoring that provides visibility into your infrastructure performance, application health, and operational metrics essential for maintaining reliable AWS workloads.
