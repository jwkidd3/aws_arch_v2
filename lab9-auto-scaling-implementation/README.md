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

## Architecture Overview

We'll build a dynamic scaling web application architecture with these components:

- **Launch Template** with user data for web server configuration
- **Auto Scaling Group** managing instances across multiple AZs
- **Application Load Balancer** distributing traffic
- **Target Tracking Scaling** based on CPU utilization
- **CloudWatch Monitoring** for scaling metrics

## Task 1: Prepare Infrastructure for Auto Scaling

**Duration:** 15 minutes

### Step 1: Verify VPC Setup

1. **Navigate to VPC Console:**
   - In AWS Management Console, go to **VPC** service
   - Verify you have a VPC with public subnets across multiple AZs

2. **If VPC not available, create basic setup:**
   - **VPC CIDR:** 10.0.0.0/16
   - **Public Subnet 1:** 10.0.1.0/24 (us-east-1a)
   - **Public Subnet 2:** 10.0.2.0/24 (us-east-1b)
   - **Internet Gateway** attached

### Step 2: Create Security Group for Auto Scaling

1. **Navigate to EC2 Console:**
   - Go to **Security Groups** in the left navigation
   - Click **Create security group**

2. **Security Group Configuration:**
   - **Security group name:** `USERNAME-asg-sg` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** Security group for Auto Scaling web servers
   - **VPC:** Select your VPC
   - **Inbound rules:**
     - HTTP (80) from 0.0.0.0/0
     - SSH (22) from 0.0.0.0/0
   - Click **Create security group**

### Step 3: Create Application Load Balancer

1. **Navigate to Load Balancers:**
   - In EC2 Console, click **Load Balancers**
   - Click **Create load balancer**

2. **Create ALB:**
   - Choose **Application Load Balancer**
   - **Name:** `USERNAME-asg-alb` ⚠️ **Replace USERNAME with your assigned username**
   - **Scheme:** Internet-facing
   - **VPC:** Select your VPC
   - **Mappings:** Select both public subnets
   - **Security groups:** Select `USERNAME-asg-sg` ⚠️ **Use your username**

3. **Create Target Group:**
   - **Name:** `USERNAME-asg-tg` ⚠️ **Replace USERNAME with your assigned username**
   - **Protocol:** HTTP, Port 80
   - **Health check path:** /
   - **Health check interval:** 30 seconds
   - **Healthy threshold:** 2
   - **Unhealthy threshold:** 5
   - Click **Create load balancer**

## Task 2: Create Launch Template

**Duration:** 15 minutes

### Step 1: Create Launch Template

1. **Navigate to Launch Templates:**
   - In EC2 Console, go to **Launch Templates**
   - Click **Create launch template**

2. **Template Details:**
   - **Launch template name:** `USERNAME-asg-template` ⚠️ **Replace USERNAME with your assigned username**
   - **Template version description:** Auto Scaling web server template
   - **Auto Scaling guidance:** Provide guidance to help me set up a template

3. **Launch Template Contents:**
   - **AMI:** Amazon Linux 2023 AMI
   - **Instance type:** t2.micro (Free tier eligible)
   - **Key pair:** Select existing or create new: `USERNAME-asg-keypair`
   - **Security groups:** Select `USERNAME-asg-sg` ⚠️ **Use your username**

### Step 2: Configure User Data Script

Add the following script in **Advanced details** → **User data** section:

```bash
#!/bin/bash
yum update -y
yum install -y httpd stress
systemctl start httpd
systemctl enable httpd

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create main page with auto scaling information
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Auto Scaling Instance - USERNAME</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
        .container { max-width: 800px; margin: 0 auto; text-align: center; }
        .instance-info { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; margin: 20px 0; }
        .status { background: #4CAF50; padding: 10px; border-radius: 5px; display: inline-block; animation: pulse 2s infinite; }
        @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.7; } 100% { opacity: 1; } }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Auto Scaling Instance</h1>
        <h2>Owned by: USERNAME</h2>
        <div class="status">✅ Instance is Running</div>
        <div class="instance-info">
            <h3>Instance Details:</h3>
            <p><strong>Instance ID:</strong> INSTANCE_ID_PLACEHOLDER</p>
            <p><strong>Availability Zone:</strong> AZ_PLACEHOLDER</p>
            <p><strong>Private IP:</strong> PRIVATE_IP_PLACEHOLDER</p>
        </div>
        <div style="margin-top: 30px;">
            <p>This instance was launched by Auto Scaling</p>
            <p><a href="/stress-test.html" style="color: #ffeb3b;">CPU Load Test Page</a></p>
        </div>
    </div>
</body>
</html>
HTML

# Create stress test page for load generation
cat > /var/www/html/stress-test.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Load Test - USERNAME</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f0f0f0; }
        .container { max-width: 800px; margin: 0 auto; }
        .button { background: #007cba; color: white; padding: 15px 30px; border: none; border-radius: 5px; cursor: pointer; margin: 10px; font-size: 16px; }
        .button:hover { background: #005a87; }
        .status { background: white; padding: 20px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #007cba; }
        .warning { background: #fff3cd; border-left-color: #ffc107; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Load Testing Interface</h1>
        <div class="status">
            <h3>Instance: INSTANCE_ID_PLACEHOLDER</h3>
            <p>Use these buttons to generate CPU load for Auto Scaling testing</p>
        </div>
        
        <div class="warning">
            <strong>⚠️ Important:</strong> These commands generate actual CPU load. Use responsibly for testing Auto Scaling only.
        </div>
        
        <h3>CPU Load Tests:</h3>
        <button class="button" onclick="alert('Light Load: stress --cpu 1 --timeout 300s')">
            Light Load (1 CPU, 5 min)
        </button>
        <button class="button" onclick="alert('Heavy Load: stress --cpu 2 --timeout 600s')">
            Heavy Load (2 CPU, 10 min)
        </button>
        <button class="button" onclick="alert('Stop Load: pkill -f stress')">
            Stop Load Test
        </button>
        
        <p><a href="/">← Back to Main Page</a></p>
    </div>
</body>
</html>
HTML

# Replace placeholders with actual values
sed -i "s/INSTANCE_ID_PLACEHOLDER/$INSTANCE_ID/g" /var/www/html/index.html
sed -i "s/AZ_PLACEHOLDER/$AZ/g" /var/www/html/index.html
sed -i "s/PRIVATE_IP_PLACEHOLDER/$PRIVATE_IP/g" /var/www/html/index.html
sed -i "s/INSTANCE_ID_PLACEHOLDER/$INSTANCE_ID/g" /var/www/html/stress-test.html

# Set proper permissions
chown -R apache:apache /var/www/html/
chmod -R 644 /var/www/html/

# Log completion
echo "Launch template user data completed at $(date)" >> /var/log/launch-template.log
```

4. **Create Launch Template:**
   - Review all settings
   - Click **Create launch template**

⚠️ **Important:** After creating the launch template, manually edit the user data to replace `USERNAME` with your actual assigned username in both HTML files.

## Task 3: Create Auto Scaling Group

**Duration:** 10 minutes

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
   - **Target groups:** Select `USERNAME-asg-tg` ⚠️ **Use your username**
   - **Health checks:** Turn on Elastic Load Balancing health checks
   - **Health check grace period:** 300 seconds
   - **Enable group metrics collection in CloudWatch:** ✅ Check this box
   - Click **Next**

5. **Configure Group Size and Scaling:**
   - **Desired capacity:** 2
   - **Minimum capacity:** 1
   - **Maximum capacity:** 6
   - **Scaling policies:** Target tracking scaling policy
   - **Metric type:** Average CPU utilization
   - **Target value:** 50 (percent)
   - **Instance warmup:** 300 seconds
   - Click **Next**

6. **Add Notifications (Optional):**
   - Skip or configure SNS notifications if desired
   - Click **Next**

7. **Add Tags:**
   - Add tag: **Key:** Name, **Value:** `USERNAME-asg-instance` ⚠️ **Use your username**
   - Add tag: **Key:** Owner, **Value:** `USERNAME` ⚠️ **Use your username**
   - Add tag: **Key:** Lab, **Value:** Lab9-AutoScaling
   - Click **Next**

8. **Review and Create:**
   - Review all settings
   - Click **Create Auto Scaling group**

### Step 2: Verify Initial Setup

1. **Monitor Instance Launch:**
   - Go to **EC2** → **Instances**
   - Wait for 2 instances to launch (may take 3-5 minutes)
   - Verify instances are in "running" state

2. **Check Load Balancer Integration:**
   - Go to **Target Groups**
   - Select your target group
   - Verify instances are registered and healthy

## Task 4: Test Auto Scaling Policies

**Duration:** 15 minutes

### Step 1: Access Load Balancer

1. **Get Load Balancer DNS:**
   - Go to **Load Balancers**
   - Copy the DNS name of your ALB
   - Example: `USERNAME-asg-alb-1234567890.us-east-1.elb.amazonaws.com`

2. **Test Web Application:**
   - Open the DNS name in your browser
   - Verify the web page loads and shows instance information
   - Navigate to `/stress-test.html` to access the load testing page

### Step 2: Generate CPU Load

1. **Connect to Instance:**
   - SSH to one of the running instances
   - Use EC2 Instance Connect or your key pair

2. **Start Load Test:**
   - Run: `stress --cpu 2 --timeout 600s`
   - This will generate high CPU utilization for 10 minutes

3. **Monitor Scaling Activity:**
   - Go to **Auto Scaling Groups** → Your ASG
   - Click **Activity** tab to monitor scaling events
   - Go to **CloudWatch** → **Metrics** → **EC2** → **By Auto Scaling Group**
   - Monitor **CPUUtilization** metric

### Step 3: Observe Scale-Out

1. **Watch for Scale-Out:**
   - After 5-10 minutes of high CPU, new instances should launch
   - Monitor in **EC2** → **Instances**
   - Check **Auto Scaling Groups** → **Activity** tab

2. **Verify Load Distribution:**
   - Refresh the web page multiple times
   - Verify traffic is distributed across instances
   - Check instance IDs changing as you refresh

### Step 4: Test Scale-In

1. **Stop Load Test:**
   - Run: `pkill -f stress`
   - Or wait for the timeout to complete

2. **Monitor Scale-In:**
   - After CPU drops below 50% for several minutes, excess instances will terminate
   - Monitor scaling activity in Auto Scaling Groups console

## Cleanup Instructions

⚠️ **Important:** Clean up resources to avoid charges

### Step 1: Delete Auto Scaling Group

1. **Set Capacity to Zero:**
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

## Troubleshooting

### Common Issues and Solutions

**Issue: Instances not launching**
- **Solution:** Check launch template configuration, AMI availability, and subnet settings
- **Verify:** Security group rules allow required traffic

**Issue: Load balancer health checks failing**
- **Solution:** Verify Apache is running on instances and security group allows HTTP traffic
- **Debug:** Check instance logs and test direct access via public IP

**Issue: Auto Scaling not triggering**
- **Solution:** Verify CloudWatch metrics are publishing and scaling policy configuration
- **Wait:** Allow sufficient time for metric evaluation periods (usually 5-10 minutes)

**Issue: Instances stuck in pending state**
- **Solution:** Check service limits, AZ capacity, and user data script errors
- **Review:** Instance system logs for boot failures

**Issue: Can't generate CPU load**
- **Solution:** Ensure stress utility is installed in user data script
- **Alternative:** Use manual CPU load: `dd if=/dev/zero of=/dev/null`

## Key Concepts Learned

1. **Auto Scaling Architecture:**
   - Launch templates vs launch configurations
   - Auto Scaling groups and their components
   - Integration with Elastic Load Balancing

2. **Scaling Policies:**
   - Target tracking scaling based on CPU utilization
   - Cooldown periods and warmup times
   - Scaling policy evaluation periods

3. **Monitoring and Metrics:**
   - CloudWatch integration with Auto Scaling
   - CPU utilization metrics and thresholds
   - Scaling activity monitoring

4. **Cost Optimization:**
   - Dynamic capacity management based on demand
   - Resource utilization optimization
   - Understanding scaling efficiency

5. **High Availability:**
   - Multi-AZ deployment strategies
   - Health check configurations
   - Automatic instance replacement

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

## Next Steps

- **Lab 10:** CloudWatch Monitoring & Alerts
- **Advanced Topics:** Blue-green deployments with Auto Scaling, cross-region scaling
- **Real-world Applications:** Microservices scaling, seasonal traffic patterns

---

**Lab Duration:** 45 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Labs 1-8 completion, understanding of EC2 and Load Balancing

