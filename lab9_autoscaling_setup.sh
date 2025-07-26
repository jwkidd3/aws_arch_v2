#!/bin/bash

# Lab 9 Setup Script: Auto Scaling Implementation
# AWS Architecting Course - Day 3, Session 1
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
    print_header "AWS Architecting Course - Lab 9 Setup"
    print_status "Setting up Auto Scaling Implementation Lab"
    
    # Create lab directory structure
    LAB_DIR="lab9-auto-scaling-implementation"
    
    if [ -d "$LAB_DIR" ]; then
        print_warning "Directory $LAB_DIR already exists. Removing and recreating..."
        rm -rf "$LAB_DIR"
    fi
    
    mkdir -p "$LAB_DIR"
    cd "$LAB_DIR"
    
    print_status "Creating lab files in directory: $LAB_DIR"
    
    # Create README.md with lab instructions
    cat > README.md << 'EOF'
# Lab 9: Auto Scaling Implementation

**Duration:** 45 minutes  
**Objective:** Implement AWS Auto Scaling with launch templates, configure scaling policies, and test dynamic scaling based on CloudWatch metrics.

## Prerequisites
- Completion of previous labs (VPC, EC2, AMI, Load Balancer basics)
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Create and configure launch templates for Auto Scaling
- Set up Auto Scaling groups with proper configuration
- Configure target tracking and step scaling policies
- Test automatic scaling based on CPU utilization
- Monitor scaling activities through CloudWatch
- Understand cost implications of dynamic scaling

---

## Task 1: Prepare Infrastructure for Auto Scaling (15 minutes)

### Step 1: Verify VPC Setup
1. **Navigate to VPC Console:**
   - In AWS Management Console, go to **VPC** service
   - Verify you have a VPC with public and private subnets across multiple AZs
   - If not available, create a basic VPC setup:
     - **VPC CIDR:** 10.0.0.0/24
     - **Public Subnet 1:** 10.0.0.0/26 (us-east-1a)
     - **Public Subnet 2:** 10.0.0.64/26 (us-east-1b)
     - **Internet Gateway** attached

### Step 2: Create Security Group for Auto Scaling
1. **Navigate to EC2 Console:**
   - Go to **Security Groups** in the left navigation
   - Click **Create security group**

2. **Configure Security Group:**
   - **Security group name:** `USERNAME-asg-sg` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** `Security group for Auto Scaling group instances`
   - **VPC:** Select your VPC
   - **Inbound rules:**
     - **Rule 1:** HTTP (80) from 0.0.0.0/0
     - **Rule 2:** SSH (22) from 0.0.0.0/0
     - **Rule 3:** HTTPS (443) from 0.0.0.0/0
   - Click **Create security group**

### Step 3: Create Application Load Balancer
1. **Navigate to Load Balancers:**
   - In EC2 console, go to **Load Balancers**
   - Click **Create Load Balancer**
   - Choose **Application Load Balancer**

2. **Basic Configuration:**
   - **Load balancer name:** `USERNAME-asg-alb` ⚠️ **Replace USERNAME with your assigned username**
   - **Scheme:** Internet-facing
   - **IP address type:** IPv4

3. **Network Mapping:**
   - **VPC:** Select your VPC
   - **Mappings:** Select both public subnets in different AZs

4. **Security Groups:**
   - Select the security group: `USERNAME-asg-sg` ⚠️ **Use your username**

5. **Listeners and Routing:**
   - **Protocol:** HTTP
   - **Port:** 80
   - **Default action:** Create new target group
     - **Target group name:** `USERNAME-asg-tg` ⚠️ **Replace USERNAME with your assigned username**
     - **Target type:** Instances
     - **Protocol:** HTTP
     - **Port:** 80
     - **Health check path:** /
   - Click **Create load balancer**

---

## Task 2: Create Launch Template (15 minutes)

### Step 1: Create Launch Template
1. **Navigate to Launch Templates:**
   - In EC2 console, go to **Launch Templates**
   - Click **Create launch template**

2. **Launch Template Details:**
   - **Launch template name:** `USERNAME-asg-template` ⚠️ **Replace USERNAME with your assigned username**
   - **Template version description:** `Web server template for auto scaling`

3. **Application and OS Images:**
   - **AMI:** Amazon Linux 2023 AMI
   - Keep default settings

4. **Instance Type:**
   - **Instance type:** t2.micro

5. **Key Pair:**
   - **Key pair name:** Create new or select existing
   - If creating new: `USERNAME-asg-keypair` ⚠️ **Replace USERNAME with your assigned username**

6. **Network Settings:**
   - **Subnet:** Don't include in launch template (will be specified in ASG)
   - **Security groups:** `USERNAME-asg-sg` ⚠️ **Use your username**
   - **Auto-assign public IP:** Enable

7. **Storage:**
   - Keep default (8 GB gp3)

8. **Advanced Details - User Data:**
   ```bash
   #!/bin/bash
   # Update system
   yum update -y
   
   # Install and configure Apache
   yum install -y httpd
   systemctl start httpd
   systemctl enable httpd
   
   # Install stress tool for testing
   yum install -y stress
   
   # Get instance metadata
   INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
   AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
   PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
   
   # Create custom web page
   cat > /var/www/html/index.html << HTML
   <!DOCTYPE html>
   <html>
   <head>
       <title>Auto Scaling Instance - USERNAME</title>
       <style>
           body { 
               font-family: Arial, sans-serif; 
               text-align: center; 
               background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
               color: white; 
               margin: 0; 
               padding: 50px;
           }
           .container { 
               background: rgba(255,255,255,0.1); 
               padding: 40px; 
               border-radius: 15px; 
               backdrop-filter: blur(10px); 
               display: inline-block; 
           }
           .instance-info { 
               background: rgba(255,255,255,0.2); 
               padding: 15px; 
               border-radius: 5px; 
               margin: 20px 0; 
           }
           .status { 
               font-size: 24px; 
               margin: 20px 0; 
               animation: pulse 2s infinite;
           }
           @keyframes pulse {
               0% { opacity: 1; }
               50% { opacity: 0.7; }
               100% { opacity: 1; }
           }
       </style>
       <script>
           function updateTime() {
               document.getElementById('time').innerHTML = new Date().toLocaleString();
           }
           setInterval(updateTime, 1000);
       </script>
   </head>
   <body>
       <div class="container">
           <h1>🚀 Auto Scaling Instance</h1>
           <h2>Owned by: USERNAME</h2>
           <div class="status">✅ Instance is Running</div>
           <div class="instance-info">
               <h3>Instance Details:</h3>
               <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
               <p><strong>Availability Zone:</strong> $AZ</p>
               <p><strong>Private IP:</strong> $PRIVATE_IP</p>
               <p><strong>Current Time:</strong> <span id="time"></span></p>
           </div>
           <div style="margin-top: 30px;">
               <p>This instance was launched by Auto Scaling</p>
               <p><a href="/load-test.html" style="color: #ffeb3b;">Load Test Page</a></p>
           </div>
       </div>
   </body>
   </html>
HTML
   
   # Create load test page
   cat > /var/www/html/load-test.html << HTML
   <!DOCTYPE html>
   <html>
   <head>
       <title>Load Test - USERNAME</title>
       <style>
           body { font-family: Arial, sans-serif; padding: 20px; background: #f0f0f0; }
           .button { 
               background: #007cba; 
               color: white; 
               padding: 15px 30px; 
               border: none; 
               border-radius: 5px; 
               cursor: pointer; 
               margin: 10px; 
               font-size: 16px;
           }
           .button:hover { background: #005a87; }
           .status { 
               background: white; 
               padding: 20px; 
               border-radius: 5px; 
               margin: 20px 0; 
               border-left: 4px solid #007cba;
           }
       </style>
   </head>
   <body>
       <h1>Load Testing Interface</h1>
       <div class="status">
           <h3>Instance: $INSTANCE_ID</h3>
           <p>Use these buttons to generate CPU load for Auto Scaling testing</p>
       </div>
       
       <h3>CPU Load Tests:</h3>
       <button class="button" onclick="runCommand('stress --cpu 1 --timeout 300s')">
           Light Load (1 CPU, 5 min)
       </button>
       <button class="button" onclick="runCommand('stress --cpu 2 --timeout 600s')">
           Heavy Load (2 CPU, 10 min)
       </button>
       <button class="button" onclick="runCommand('pkill -f stress')">
           Stop Load Test
       </button>
       
       <div id="output" class="status" style="display:none;">
           <h4>Command Output:</h4>
           <pre id="result"></pre>
       </div>
       
       <script>
           function runCommand(cmd) {
               document.getElementById('output').style.display = 'block';
               document.getElementById('result').textContent = 'Executing: ' + cmd + '\\n\\nThis will run in the background on the server.';
           }
       </script>
       
       <p><a href="/">← Back to Main Page</a></p>
   </body>
   </html>
HTML
   
   # Set proper permissions
   chown -R apache:apache /var/www/html/
   chmod -R 644 /var/www/html/
   
   # Replace USERNAME placeholder with actual username if provided
   # Note: In actual deployment, this would be handled by the launch template
   
   # Log completion
   echo "Launch template user data completed at $(date)" >> /var/log/launch-template.log
   ```

9. **Create Launch Template:**
   - Review all settings
   - Click **Create launch template**

⚠️ **Important:** After creating the launch template, manually edit the user data to replace `USERNAME` with your actual assigned username in both HTML files.

---

## Task 3: Create Auto Scaling Group (10 minutes)

### Step 1: Create Auto Scaling Group
1. **Navigate to Auto Scaling Groups:**
   - In EC2 console, go to **Auto Scaling Groups**
   - Click **Create Auto Scaling group**

2. **Choose Launch Template:**
   - **Auto Scaling group name:** `USERNAME-asg` ⚠️ **Replace USERNAME with your assigned username**
   - **Launch template:** Select `USERNAME-asg-template` ⚠️ **Use your username**
   - **Version:** Latest
   - Click **Next**

3. **Choose Instance Launch Options:**
   - **VPC:** Select your VPC
   - **Availability Zones and subnets:** Select both public subnets
   - Click **Next**

4. **Configure Advanced Options:**
   - **Load balancing:** Attach to an existing load balancer
   - **Choose from your load balancer target groups:** `USERNAME-asg-tg` ⚠️ **Use your username**
   - **Health checks:**
     - **EC2:** Enabled
     - **ELB:** Enabled
     - **Health check grace period:** 300 seconds
   - **Additional settings:**
     - **Enable group metrics collection within CloudWatch:** Checked
   - Click **Next**

5. **Configure Group Size and Scaling Policies:**
   - **Group size:**
     - **Desired capacity:** 2
     - **Minimum capacity:** 1
     - **Maximum capacity:** 6
   - **Scaling policies:** Target tracking scaling policy
     - **Policy name:** `USERNAME-cpu-tracking` ⚠️ **Replace USERNAME with your assigned username**
     - **Metric type:** Average CPU Utilization
     - **Target value:** 50
     - **Instance warmup:** 300 seconds
   - Click **Next**

6. **Add Notifications (Optional):**
   - **Skip** for this lab
   - Click **Next**

7. **Add Tags:**
   - **Key:** Name, **Value:** `USERNAME-asg-instance` ⚠️ **Replace USERNAME with your assigned username**
   - **Key:** Owner, **Value:** USERNAME ⚠️ **Replace USERNAME with your assigned username**
   - **Key:** Lab, **Value:** Auto-Scaling-Lab
   - Click **Next**

8. **Review and Create:**
   - Review all settings
   - Click **Create Auto Scaling group**

### Step 2: Monitor Initial Launch
1. **Watch Auto Scaling Activity:**
   - Go to **Auto Scaling Groups** → Select your ASG
   - Click **Activity** tab
   - Monitor the launch of initial instances

2. **Verify Load Balancer Integration:**
   - Go to **Load Balancers** → Select your ALB
   - Click **Target groups** → Select your target group
   - Verify instances are being registered and become healthy

3. **Test Application:**
   - Get your Load Balancer DNS name from the ALB details
   - Open in browser: `http://YOUR_ALB_DNS_NAME`
   - Verify you see your custom web page
   - Refresh several times to see different instance IDs (load balancing)

---

## Task 4: Test Auto Scaling Policies (5 minutes)

### Step 1: Generate CPU Load
1. **Access Load Test Page:**
   - Navigate to: `http://YOUR_ALB_DNS_NAME/load-test.html`
   - Click on "Heavy Load (2 CPU, 10 min)" button

2. **Alternative Manual Method:**
   - SSH into one of the running instances
   - Run: `stress --cpu 2 --timeout 600s`

### Step 2: Monitor Scaling Activity
1. **CloudWatch Metrics:**
   - Go to **CloudWatch** → **Metrics** → **EC2** → **By Auto Scaling Group**
   - Monitor CPU Utilization for your ASG
   - Watch for metrics to exceed 50%

2. **Auto Scaling Activity:**
   - Return to your Auto Scaling Group
   - Click **Activity** tab
   - Watch for scale-out activities to begin

3. **Instance Count:**
   - Go to **EC2** → **Instances**
   - Filter by your tag (Owner: USERNAME)
   - Watch new instances launch

### Step 3: Verify Scale-Out
1. **Wait for New Instances:**
   - New instances should launch when CPU > 50% for ~5 minutes
   - Monitor until you see additional instances running

2. **Test Load Distribution:**
   - Refresh your load balancer URL multiple times
   - Verify traffic is distributed across more instances

3. **Monitor Scale-In:**
   - Stop the load test: `pkill -f stress`
   - Wait 10-15 minutes for CPU to normalize
   - Watch instances scale back down to desired capacity

---

## Advanced Exercises (Optional)

### Exercise 1: Create Step Scaling Policy
Create an additional scaling policy with specific steps:

```bash
# Scale-out policy
Scale out by 2 instances when CPU > 70%
Scale out by 1 instance when CPU > 60%

# Scale-in policy  
Scale in by 1 instance when CPU < 30%
```

### Exercise 2: Custom CloudWatch Alarm
Create custom alarms for:
- Network bytes in/out
- Request count per target
- Response time

### Exercise 3: Scheduled Scaling
Set up scheduled scaling for:
- Scale up during business hours (9 AM - 5 PM)
- Scale down during off-hours

---

## Monitoring and Analysis

### Key Metrics to Monitor
1. **Auto Scaling Group Metrics:**
   - Group Desired Capacity
   - Group In Service Instances
   - Group Total Instances

2. **Instance Metrics:**
   - CPU Utilization
   - Network In/Out
   - Status Check Failed

3. **Load Balancer Metrics:**
   - Request Count
   - Target Response Time
   - Healthy Host Count

### Understanding Scaling Decisions
1. **Scaling Activities:**
   - Check ASG Activity history
   - Review scaling triggers and cooldowns
   - Analyze metric breach durations

2. **Cost Analysis:**
   - Monitor instance hours consumed
   - Understand cost implications of scaling
   - Evaluate scaling efficiency

---

## Cleanup Instructions

**⚠️ Important:** Clean up resources to avoid charges

### Step 1: Delete Auto Scaling Group
1. **Modify ASG Capacity:**
   - Go to your Auto Scaling Group
   - Click **Edit**
   - Set Desired, Minimum, and Maximum capacity to 0
   - Click **Update**
   - Wait for all instances to terminate

2. **Delete Auto Scaling Group:**
   - Select your ASG: `USERNAME-asg`
   - **Actions** → **Delete**
   - Type the ASG name to confirm
   - Click **Delete**

### Step 2: Delete Launch Template
1. **Delete Launch Template:**
   - Go to **Launch Templates**
   - Select `USERNAME-asg-template`
   - **Actions** → **Delete template**
   - Confirm deletion

### Step 3: Delete Load Balancer Resources
1. **Delete Load Balancer:**
   - Go to **Load Balancers**
   - Select `USERNAME-asg-alb`
   - **Actions** → **Delete**
   - Confirm deletion

2. **Delete Target Group:**
   - Go to **Target Groups**
   - Select `USERNAME-asg-tg`
   - **Actions** → **Delete**
   - Confirm deletion

### Step 4: Delete Security Group
1. **Delete Security Group:**
   - Go to **Security Groups**
   - Select `USERNAME-asg-sg`
   - **Actions** → **Delete security group**
   - Confirm deletion

### Step 5: Clean Up Key Pairs (if created new)
1. **Delete Key Pair:**
   - Go to **Key Pairs**
   - Select `USERNAME-asg-keypair` (if created)
   - **Actions** → **Delete**
   - Confirm deletion

---

## Troubleshooting

### Common Issues and Solutions

**Issue: Instances not launching**
- **Solution:** Check launch template configuration, AMI availability, and subnet settings
- **Verify:** Security group rules allow required traffic

**Issue: Load balancer health checks failing**
- **Solution:** Verify Apache is running on instances
- **Check:** Security group allows HTTP traffic on port 80
- **Debug:** Access instance directly via public IP

**Issue: Auto Scaling not triggering**
- **Solution:** Verify CloudWatch metrics are publishing
- **Check:** Scaling policy configuration and thresholds
- **Wait:** Allow sufficient time for metric evaluation periods

**Issue: Instances stuck in pending state**
- **Solution:** Check service limits and AZ capacity
- **Verify:** User data script is not causing boot failures
- **Review:** Instance system logs

---

## Key Concepts Learned

1. **Auto Scaling Architecture:**
   - Launch templates vs launch configurations
   - Auto Scaling groups and their components
   - Integration with Elastic Load Balancing

2. **Scaling Policies:**
   - Target tracking scaling
   - Step scaling vs simple scaling
   - Cooldown periods and warmup times

3. **Monitoring and Metrics:**
   - CloudWatch integration with Auto Scaling
   - Custom metrics and alarms
   - Scaling activity monitoring

4. **Cost Optimization:**
   - Dynamic capacity management
   - Resource utilization optimization
   - Scaling efficiency metrics

5. **High Availability:**
   - Multi-AZ deployment strategies
   - Health check configurations
   - Instance replacement mechanisms

---

## Validation Checklist

- [ ] Successfully created launch template with user data script
- [ ] Configured Auto Scaling group with proper capacity settings
- [ ] Integrated ASG with Application Load Balancer
- [ ] Set up target tracking scaling policy based on CPU utilization
- [ ] Generated load and observed scale-out behavior
- [ ] Monitored scaling activities through CloudWatch and ASG console
- [ ] Verified load balancer distributed traffic across instances
- [ ] Observed scale-in behavior after load was removed
- [ ] Cleaned up all resources properly

---

## Next Steps

- **Lab 10:** CloudWatch Monitoring & Alerts
- **Advanced Topics:** Blue-green deployments with Auto Scaling, cross-region scaling
- **Real-world Applications:** Microservices scaling, seasonal traffic patterns

---

**Lab Duration:** 45 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Labs 1-8 completion, understanding of EC2 and Load Balancing

EOF

    # Create lab progress tracking
    cat > lab-progress.md << 'EOF'
# Lab 9 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: Prepare Infrastructure for Auto Scaling
- [ ] Verified VPC setup with public subnets in multiple AZs
- [ ] Created security group: `USERNAME-asg-sg` (with your username)
- [ ] Created Application Load Balancer: `USERNAME-asg-alb`
- [ ] Created target group: `USERNAME-asg-tg`
- [ ] Verified ALB is in active state

### Task 2: Create Launch Template
- [ ] Created launch template: `USERNAME-asg-template` (with your username)
- [ ] Configured Amazon Linux 2023 AMI with t2.micro instance type
- [ ] Added comprehensive user data script for web server setup
- [ ] Replaced USERNAME placeholder in user data with actual username
- [ ] Verified launch template creation successful

### Task 3: Create Auto Scaling Group
- [ ] Created Auto Scaling group: `USERNAME-asg` (with your username)
- [ ] Configured capacity: Desired=2, Min=1, Max=6
- [ ] Attached to load balancer target group
- [ ] Enabled CloudWatch group metrics collection
- [ ] Set up target tracking scaling policy (CPU 50%)
- [ ] Added appropriate tags with username
- [ ] Verified initial instances launched successfully

### Task 4: Test Auto Scaling Policies
- [ ] Accessed load balancer URL and verified web application
- [ ] Generated CPU load using stress test
- [ ] Monitored CloudWatch metrics for CPU utilization
- [ ] Observed scale-out activity when CPU exceeded threshold
- [ ] Verified new instances were added to load balancer
- [ ] Stopped load test and monitored scale-in behavior
- [ ] Confirmed instances scaled back to desired capacity

### Advanced Exercises (Optional)
- [ ] Created step scaling policies with multiple thresholds
- [ ] Set up custom CloudWatch alarms for additional metrics
- [ ] Configured scheduled scaling policies

### Cleanup
- [ ] Set ASG capacity to 0 and waited for instance termination
- [ ] Deleted Auto Scaling group (USERNAME-asg)
- [ ] Deleted launch template (USERNAME-asg-template)
- [ ] Deleted Application Load Balancer (USERNAME-asg-alb)
- [ ] Deleted target group (USERNAME-asg-tg)
- [ ] Deleted security group (USERNAME-asg-sg)
- [ ] Removed key pair if created new (USERNAME-asg-keypair)
- [ ] Verified all resources cleaned up

## Notes

**Your Username:** ________________

**Resource Names (with your username):**
- Auto Scaling Group: ________________-asg
- Launch Template: ________________-asg-template
- Load Balancer: ________________-asg-alb
- Target Group: ________________-asg-tg
- Security Group: ________________-asg-sg

**Load Balancer DNS:** ________________

**Scaling Events Observed:**
- Scale-out triggered at: ________________
- Number of instances scaled to: ________________
- Scale-in triggered at: ________________
- Final number of instances: ________________

**CloudWatch Metrics:**
- Maximum CPU utilization reached: ________________%
- Scaling policy evaluation period: ________________
- Cooldown period observed: ________________

**Issues Encountered:**


**Solutions Applied:**


**Key Insights:**


**Time Completed:** ________________

EOF

    # Create summary of created files
    cat > FILES.md << 'EOF'
# Lab 9 Files

This directory contains all files needed for Lab 9: Auto Scaling Implementation.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **FILES.md** - This file, describing all lab files

## Lab Overview

This lab focuses on:
- Creating launch templates with comprehensive user data scripts
- Configuring Auto Scaling groups with proper capacity management
- Setting up target tracking scaling policies based on CloudWatch metrics
- Testing automatic scaling behavior under load
- Integrating Auto Scaling with Application Load Balancers
- Monitoring scaling activities and cost implications

## Key Learning Points

1. **Launch Templates:** Modern approach to instance configuration with versioning
2. **Auto Scaling Groups:** Dynamic capacity management across availability zones
3. **Scaling Policies:** Target tracking vs step scaling strategies
4. **Load Balancer Integration:** Automatic registration and health checks
5. **CloudWatch Monitoring:** Metrics collection and alarm-based scaling
6. **Cost Optimization:** Understanding scaling efficiency and resource utilization

## Usage Instructions

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Remember to replace USERNAME with your assigned username throughout
4. Follow cleanup instructions carefully to remove all resources

## Important Notes

- All resource names must include your username prefix for uniqueness
- This lab builds on previous VPC and EC2 knowledge
- Focus on understanding scaling triggers and cooldown periods
- Monitor CloudWatch metrics throughout the exercise
- Pay attention to cost implications of scaling decisions

## Auto Scaling Architecture

```
Internet Gateway
     |
Application Load Balancer
     |
Target Group
     |
Auto Scaling Group
 /       |        \
Instance Instance Instance
(Multi-AZ deployment)
```

## Scaling Policy Logic

```
CPU > 50% for 5 minutes → Scale Out
CPU < 50% for 5 minutes → Scale In
Cooldown: 300 seconds
Warmup: 300 seconds
```

EOF

    print_status "Lab files created successfully!"
    print_status "Lab directory: $LAB_DIR"
    
    echo ""
    print_header "Lab 9 Setup Complete"
    echo -e "${GREEN}✅ Lab directory created: ${BLUE}$LAB_DIR${NC}"
    echo -e "${GREEN}✅ README.md with comprehensive instructions${NC}"
    echo -e "${GREEN}✅ Progress tracking checklist${NC}"
    echo -e "${GREEN}✅ Documentation files${NC}"
    
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
    echo -e "${BLUE}Focus: Auto Scaling Implementation${NC}"
    echo ""
    echo -e "${YELLOW}Key Topics:${NC}"
    echo "• Launch template creation and configuration"
    echo "• Auto Scaling group setup and capacity management"
    echo "• Target tracking scaling policies"
    echo "• Load balancer integration and health checks"
    echo "• CloudWatch metrics and scaling triggers"
    echo "• Cost optimization through dynamic scaling"
    echo ""
    echo -e "${YELLOW}Prerequisites:${NC}"
    echo "• Understanding of VPC, EC2, and Load Balancing concepts"
    echo "• Completion of Labs 1-8"
    echo "• Basic knowledge of CloudWatch metrics"
}

# Run main function
main "$@"