#!/bin/bash

# Lab 10 Setup Script: CloudWatch Monitoring & Alerts
# AWS Architecting Course - Day 3, Session 2
# Duration: 45 minutes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}================================================${NC}"
}

# Username placeholder - students will update this in lab instructions
USERNAME="USERNAME"

# Main function
main() {
    print_header "AWS Architecting Course - Lab 10 Setup"
    print_status "Setting up CloudWatch Monitoring & Alerts Lab"
    
    # Create lab directory structure
    LAB_DIR="lab10-cloudwatch-monitoring"
    
    if [ -d "$LAB_DIR" ]; then
        print_warning "Directory $LAB_DIR already exists. Removing and recreating..."
        rm -rf "$LAB_DIR"
    fi
    
    mkdir -p "$LAB_DIR"
    cd "$LAB_DIR"
    
    print_status "Creating lab files in directory: $LAB_DIR"
    
    # Create README.md with lab instructions
    cat > README.md << 'EOF'
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

EOF

    # Create lab progress tracking
    cat > lab-progress.md << 'EOF'
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

EOF

    # Create monitoring scripts
    mkdir -p scripts
    
    cat > scripts/generate-load.sh << 'EOF'
#!/bin/bash

# Script to generate various types of load for CloudWatch testing
# Usage: ./generate-load.sh [cpu|memory|disk|network] [duration_seconds]

LOAD_TYPE=${1:-cpu}
DURATION=${2:-300}

echo "Generating $LOAD_TYPE load for $DURATION seconds..."

case $LOAD_TYPE in
    cpu)
        echo "Starting CPU stress test..."
        if command -v stress >/dev/null 2>&1; then
            stress --cpu 2 --timeout ${DURATION}s
        else
            echo "stress command not found, using alternative method..."
            for i in {1..2}; do
                yes > /dev/null &
            done
            sleep $DURATION
            pkill yes
        fi
        ;;
    memory)
        echo "Starting memory stress test..."
        if command -v stress >/dev/null 2>&1; then
            stress --vm 1 --vm-bytes 256M --timeout ${DURATION}s
        else
            echo "Creating memory pressure..."
            dd if=/dev/zero of=/tmp/memory-test bs=1M count=256
            sleep $DURATION
            rm -f /tmp/memory-test
        fi
        ;;
    disk)
        echo "Starting disk I/O stress test..."
        for i in $(seq 1 10); do
            dd if=/dev/zero of=/tmp/testfile$i bs=1M count=50 2>/dev/null
            rm -f /tmp/testfile$i
        done
        ;;
    network)
        echo "Starting network activity..."
        for i in $(seq 1 $((DURATION/10))); do
            curl -s https://httpbin.org/bytes/1024 > /dev/null
            sleep 10
        done
        ;;
    *)
        echo "Unknown load type: $LOAD_TYPE"
        echo "Usage: $0 [cpu|memory|disk|network] [duration_seconds]"
        exit 1
        ;;
esac

echo "Load test completed!"
EOF

    chmod +x scripts/generate-load.sh

    cat > scripts/custom-metrics.sh << 'EOF'
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
EOF

    chmod +x scripts/custom-metrics.sh

    # Create CloudWatch agent config template
    cat > cloudwatch-agent-config.json << 'EOF'
{
    "agent": {
        "metrics_collection_interval": 300,
        "run_as_user": "cwagent"
    },
    "metrics": {
        "namespace": "USERNAME/DetailedMetrics",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 300
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 300,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 300,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 300
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 300
            },
            "swap": {
                "measurement": [
                    "swap_used_percent"
                ],
                "metrics_collection_interval": 300
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
                        "log_stream_name": "{instance_id}-messages"
                    },
                    {
                        "file_path": "/var/log/secure",
                        "log_group_name": "USERNAME-security-logs",
                        "log_stream_name": "{instance_id}-secure"
                    }
                ]
            }
        }
    }
}
EOF

    # Create sample dashboard JSON
    cat > dashboard-template.json << 'EOF'
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/EC2", "CPUUtilization", "InstanceId", "INSTANCE_ID" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "title": "USERNAME EC2 CPU Utilization",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/EC2", "NetworkIn", "InstanceId", "INSTANCE_ID" ],
                    [ ".", "NetworkOut", ".", "." ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "title": "USERNAME EC2 Network I/O",
                "period": 300
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 6,
            "width": 24,
            "height": 3,
            "properties": {
                "markdown": "## USERNAME Monitoring Dashboard\\n\\n**Purpose:** Monitor EC2 instance performance and health\\n**Owner:** USERNAME\\n**Created:** [Current Date]\\n\\n**Widgets:**\\n- CPU Utilization: Monitor processor usage\\n- Network I/O: Track network traffic\\n- Status Checks: Instance health monitoring"
            }
        }
    ]
}
EOF

    # Create summary of created files
    cat > FILES.md << 'EOF'
# Lab 10 Files

This directory contains all files needed for Lab 10: CloudWatch Monitoring & Alerts.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **FILES.md** - This file, describing all lab files

## Additional Resources

- **scripts/generate-load.sh** - Script to generate various types of system load for testing
- **scripts/custom-metrics.sh** - Script to send custom metrics to CloudWatch
- **cloudwatch-agent-config.json** - CloudWatch agent configuration template
- **dashboard-template.json** - Sample dashboard configuration

## Lab Overview

This lab focuses on:
- Creating comprehensive CloudWatch monitoring dashboards
- Configuring CloudWatch alarms with SNS notifications
- Implementing custom metrics and log monitoring
- Understanding CloudWatch Events and automated responses
- Learning monitoring best practices and troubleshooting

## Key Learning Points

1. **Monitoring Strategy:** Implementing proactive monitoring and alerting
2. **Dashboard Design:** Creating effective visualization and organization
3. **Alarm Configuration:** Setting appropriate thresholds and notification channels
4. **Custom Metrics:** Publishing application-specific monitoring data
5. **Automation:** Using CloudWatch for automated responses and remediation

## Usage Instructions

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Remember to replace USERNAME with your assigned username throughout
4. Use provided scripts to generate test data and metrics
5. Follow cleanup instructions carefully to remove all resources

## Important Notes

- All resource names must include your username prefix for uniqueness
- This lab builds on previous labs and prepares for Lab 11
- Focus on understanding monitoring patterns and best practices
- Test alarm functionality thoroughly before proceeding
- Document your dashboard design decisions for future reference

EOF

    print_status "Lab files created successfully!"
    print_status "Lab directory: $LAB_DIR"
    
    echo ""
    print_header "Lab 10 Setup Complete"
    echo -e "${GREEN}✅ Lab directory created: ${BLUE}$LAB_DIR${NC}"
    echo -e "${GREEN}✅ README.md with comprehensive instructions${NC}"
    echo -e "${GREEN}✅ Progress tracking checklist${NC}"
    echo -e "${GREEN}✅ Monitoring and load generation scripts${NC}"
    echo -e "${GREEN}✅ CloudWatch agent configuration template${NC}"
    echo -e "${GREEN}✅ Dashboard template and documentation${NC}"
    
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. cd $LAB_DIR"
    echo "2. cat README.md  # Read complete lab instructions"
    echo "3. Replace USERNAME with your assigned username throughout the lab"
    echo "4. Follow the step-by-step procedures"
    echo "5. Use lab-progress.md to track completion"
    
    echo ""
    echo -e "${BLUE}Lab Duration: 45 minutes${NC}"
    echo -e "${BLUE}Difficulty: Intermediate${NC}"
    echo -e "${BLUE}Focus: CloudWatch Monitoring & Alerts${NC}"
    echo ""
    echo -e "${YELLOW}Key Topics:${NC}"
    echo "• Custom CloudWatch dashboards and widgets"
    echo "• CloudWatch alarms with SNS integration"
    echo "• Custom metrics and application monitoring"
    echo "• CloudWatch Logs and Insights"
    echo "• Monitoring best practices and troubleshooting"
    echo "• Automated alerting and notification systems"
}

# Run main function
main "$@"