# Lab 8: Application Load Balancer Setup

**Duration:** 45 minutes  
**Objective:** Learn to configure Application Load Balancers (ALB) with target groups, health checks, and routing rules for highly available web applications.

## Prerequisites
- Completion of Lab 4: VPC Networking Setup
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Create and configure Application Load Balancers
- Set up target groups with health checks
- Configure routing rules for different applications
- Test load balancing across multiple instances
- Monitor ALB performance and health status
- Understand SSL termination and security integration

---

## Architecture Overview

We'll build a highly available web application architecture:
- **Application Load Balancer** in public subnets
- **Web servers** in private subnets across multiple AZs
- **Target groups** for different application tiers
- **Health checks** for automatic failover
- **Routing rules** for path-based routing

---

## Task 1: Prepare Infrastructure and Web Servers (15 minutes)

### Step 1: Launch Web Server Instances
1. **Navigate to EC2:**
   - In the AWS Management Console, go to **EC2** service
   - Click **Instances** in the left navigation menu

2. **Launch First Web Server:**
   - Click **Launch Instances**
   - **Name:** `USERNAME-web-server-1` ⚠️ **Replace USERNAME with your assigned username**
   - **AMI:** Amazon Linux 2023 AMI
   - **Instance type:** t2.micro
   - **Key pair:** Use existing `USERNAME-keypair` from previous labs ⚠️ **Use your username**
   - **VPC:** Select your custom VPC from Lab 4 (MyProdVPC)
   - **Subnet:** Select a **private subnet** (private-subnet-a)
   - **Auto-assign public IP:** Disable
   - **Security group:** Create new `USERNAME-web-sg` ⚠️ **Replace USERNAME with your assigned username**
     - **Rules:**
       - SSH (22) from VPC CIDR (10.0.0.0/26)
       - HTTP (80) from VPC CIDR (10.0.0.0/26)
       - HTTPS (443) from VPC CIDR (10.0.0.0/26)

3. **User Data Script for Web Server 1:**
   ```bash
   #!/bin/bash
   yum update -y
   yum install -y httpd
   systemctl start httpd
   systemctl enable httpd
   
   # Get instance metadata
   INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
   AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
   PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
   
   # Create main application
   cat > /var/www/html/index.html << 'HTML'
   <!DOCTYPE html>
   <html>
   <head>
       <title>Web Server 1 - USERNAME</title>
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
               min-width: 400px;
           }
           .server-info {
               background: rgba(255,255,255,0.2);
               padding: 20px;
               border-radius: 10px;
               margin: 20px 0;
           }
           .status { color: #00ff00; font-weight: bold; }
           .nav { margin: 20px 0; }
           .nav a { 
               color: #ffeb3b; 
               text-decoration: none; 
               margin: 0 10px;
               padding: 10px 20px;
               background: rgba(255,255,255,0.2);
               border-radius: 5px;
           }
       </style>
   </head>
   <body>
       <div class="container">
           <h1>🌐 Load Balanced Web Application</h1>
           <h2>Server 1 - USERNAME</h2>
           <div class="server-info">
               <h3>Server Information</h3>
               <p><strong>Instance ID:</strong> INSTANCE_ID_PLACEHOLDER</p>
               <p><strong>Availability Zone:</strong> AZ_PLACEHOLDER</p>
               <p><strong>Private IP:</strong> PRIVATE_IP_PLACEHOLDER</p>
               <p class="status">🟢 Server Status: Active</p>
           </div>
           <div class="nav">
               <a href="/">Home</a>
               <a href="/app">Application</a>
               <a href="/api">API</a>
               <a href="/health">Health Check</a>
           </div>
           <p>Served by: <strong>Web Server 1</strong></p>
       </div>
   </body>
   </html>
HTML```
   
   # Replace placeholders with actual values
   sed -i "s/INSTANCE_ID_PLACEHOLDER/$INSTANCE_ID/g" /var/www/html/index.html
   sed -i "s/AZ_PLACEHOLDER/$AZ/g" /var/www/html/index.html
   sed -i "s/PRIVATE_IP_PLACEHOLDER/$PRIVATE_IP/g" /var/www/html/index.html
   sed -i "s/USERNAME/YOUR_USERNAME_HERE/g" /var/www/html/index.html
   
   # Create application endpoints
   mkdir -p /var/www/html/app /var/www/html/api
   
   cat > /var/www/html/app/index.html << 'HTML'
   <!DOCTYPE html>
   <html>
   <head>
       <title>Application - Server 1</title>
       <style>
           body { font-family: Arial, sans-serif; text-align: center; background: #2c3e50; color: white; padding: 50px; }
           .container { background: #34495e; padding: 30px; border-radius: 10px; display: inline-block; }
       </style>
   </head>
   <body>
       <div class="container">
           <h1>📱 Application Server</h1>
           <h2>Server 1 - USERNAME</h2>
           <p>This is the application endpoint</p>
           <p><strong>Path:</strong> /app</p>
           <p><strong>Server:</strong> Web Server 1</p>
           <a href="/" style="color: #3498db;">← Back to Home</a>
       </div>
   </body>
   </html>
HTML
   
   cat > /var/www/html/api/index.html << 'HTML'
   <!DOCTYPE html>
   <html>
   <head>
       <title>API - Server 1</title>
       <style>
           body { font-family: Arial, sans-serif; text-align: center; background: #27ae60; color: white; padding: 50px; }
           .container { background: #2ecc71; padding: 30px; border-radius: 10px; display: inline-block; }
       </style>
   </head>
   <body>
       <div class="container">
           <h1>🔧 API Server</h1>
           <h2>Server 1 - USERNAME</h2>
           <p>This is the API endpoint</p>
           <p><strong>Path:</strong> /api</p>
           <p><strong>Server:</strong> Web Server 1</p>
           <a href="/" style="color: #ecf0f1;">← Back to Home</a>
       </div>
   </body>
   </html>
HTML
   
   # Create health check endpoint
   cat > /var/www/html/health/index.html << 'HTML'
   <!DOCTYPE html>
   <html>
   <head>
       <title>Health Check - Server 1</title>
   </head>
   <body>
       <h1>Health Check - Server 1</h1>
       <p>Status: OK</p>
       <p>Server: Web Server 1 - USERNAME</p>
       <p>Timestamp: $(date)</p>
   </body>
   </html>
HTML
   
   # Replace USERNAME in all files
   find /var/www/html -name "*.html" -exec sed -i "s/USERNAME/YOUR_USERNAME_HERE/g" {} \;
   ```

4. **Launch the instance**

5. **Launch Second Web Server:**
   - Repeat the process for a second instance
   - **Name:** `USERNAME-web-server-2` ⚠️ **Replace USERNAME with your assigned username**
   - **Subnet:** Select different AZ private subnet (private-subnet-b)
   - **Security group:** Use existing `USERNAME-web-sg` ⚠️ **Use your username**
   - **User Data:** Use similar script but replace "Server 1" with "Server 2" throughout

### Step 2: Update User Data for Server 2
Modify the user data script for the second server:
- Change all instances of "Server 1" to "Server 2"
- Change "Web Server 1" to "Web Server 2"
- Update the gradient colors (optional):
  ```css
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  ```

### Step 3: Verify Instance Deployment
1. **Check Instance Status:**
   - Both instances should be in "running" state
   - Status checks should be "2/2 checks passed"
   - Note the private IP addresses of both instances

2. **Test from Bastion Host (if available):**
   - If you have a bastion host in the public subnet, test connectivity:
   ```bash
   curl http://PRIVATE_IP_SERVER_1
   curl http://PRIVATE_IP_SERVER_2
   ```

---

## Task 2: Create Application Load Balancer (20 minutes)

### Step 1: Create Target Group
1. **Navigate to Target Groups:**
   - In EC2 Console, click **Target Groups** in left navigation
   - Click **Create target group**

2. **Target Group Configuration:**
   - **Choose a target type:** Instances
   - **Target group name:** `USERNAME-web-tg` ⚠️ **Replace USERNAME with your assigned username**
   - **Protocol:** HTTP
   - **Port:** 80
   - **VPC:** Select your custom VPC (MyProdVPC)
   - **Protocol version:** HTTP1

3. **Health Check Settings:**
   - **Health check protocol:** HTTP
   - **Health check path:** `/health`
   - **Health check port:** Traffic port
   - **Healthy threshold:** 2
   - **Unhealthy threshold:** 2
   - **Timeout:** 5 seconds
   - **Interval:** 30 seconds
   - **Success codes:** 200

4. **Create Target Group**

### Step 2: Register Targets
1. **Select Target Group:**
   - Select your newly created target group
   - Click **Actions** → **Register targets**

2. **Add Instances:**
   - Select both web server instances (USERNAME-web-server-1 and USERNAME-web-server-2)
   - **Port:** 80
   - Click **Include as pending below**
   - Click **Register pending targets**

3. **Monitor Health Status:**
   - Go to **Targets** tab
   - Wait for both targets to show "healthy" status
   - This may take 2-3 minutes

### Step 3: Create Application Load Balancer
1. **Navigate to Load Balancers:**
   - In EC2 Console, click **Load Balancers** in left navigation
   - Click **Create load balancer**

2. **Select Load Balancer Type:**
   - Choose **Application Load Balancer**
   - Click **Create**

3. **Basic Configuration:**
   - **Load balancer name:** `USERNAME-web-alb` ⚠️ **Replace USERNAME with your assigned username**
   - **Scheme:** Internet-facing
   - **IP address type:** IPv4

4. **Network Mapping:**
   - **VPC:** Select your custom VPC (MyProdVPC)
   - **Mappings:** Select both availability zones
     - **AZ 1:** Select public subnet (public-subnet-a)
     - **AZ 2:** Select public subnet (public-subnet-b)

5. **Security Groups:**
   - **Security groups:** Create new security group
   - **Security group name:** `USERNAME-alb-sg` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** Security group for Application Load Balancer
   - **VPC:** Your custom VPC
   - **Rules:**
     - HTTP (80) from 0.0.0.0/0
     - HTTPS (443) from 0.0.0.0/0

6. **Listeners and Routing:**
   - **Protocol:** HTTP
   - **Port:** 80
   - **Default action:** Forward to `USERNAME-web-tg` target group ⚠️ **Use your username**

7. **Create Load Balancer**

### Step 4: Verify Load Balancer Creation
1. **Check Status:**
   - Wait for ALB state to change from "provisioning" to "active"
   - This may take 2-3 minutes

2. **Note DNS Name:**
   - Copy the DNS name of your load balancer
   - Format: `USERNAME-web-alb-xxxxxxxxx.us-east-1.elb.amazonaws.com`

---

## Task 3: Configure Advanced Routing and Test Load Balancing (10 minutes)

### Step 1: Create Additional Target Groups for Path-Based Routing
1. **Create App Target Group:**
   - **Target group name:** `USERNAME-app-tg` ⚠️ **Replace USERNAME with your assigned username**
   - **Health check path:** `/app`
   - Register the same instances

2. **Create API Target Group:**
   - **Target group name:** `USERNAME-api-tg` ⚠️ **Replace USERNAME with your assigned username**
   - **Health check path:** `/api`
   - Register the same instances

### Step 2: Configure Listener Rules
1. **Edit Listener:**
   - Select your load balancer
   - Go to **Listeners** tab
   - Select the HTTP:80 listener
   - Click **View/edit rules**

2. **Add Rules:**
   - Click **Add rule** (+ icon)
   
   **Rule 1 - Application Path:**
   - **Add condition:** Path
   - **Path:** `/app*`
   - **Add action:** Forward to target group
   - **Target group:** `USERNAME-app-tg` ⚠️ **Use your username**
   - **Priority:** 100

   **Rule 2 - API Path:**
   - **Add condition:** Path
   - **Path:** `/api*`
   - **Add action:** Forward to target group
   - **Target group:** `USERNAME-api-tg` ⚠️ **Use your username**
   - **Priority:** 200

3. **Save Rules**

### Step 3: Test Load Balancing
1. **Basic Load Balancing Test:**
   - Open your browser
   - Navigate to: `http://YOUR_ALB_DNS_NAME`
   - Refresh multiple times
   - Observe traffic distribution between Server 1 and Server 2

2. **Path-Based Routing Test:**
   ```bash
   # Test different paths
   curl http://YOUR_ALB_DNS_NAME/
   curl http://YOUR_ALB_DNS_NAME/app
   curl http://YOUR_ALB_DNS_NAME/api
   curl http://YOUR_ALB_DNS_NAME/health
   ```

3. **Load Testing (Optional):**
   ```bash
   # Simple load test
   for i in {1..20}; do
     curl -s http://YOUR_ALB_DNS_NAME/ | grep "Server [12]"
   done
   ```

### Step 4: Monitor ALB Metrics
1. **CloudWatch Metrics:**
   - Go to **CloudWatch** service
   - Click **Metrics** → **All metrics**
   - Select **ApplicationELB**
   - Monitor:
     - Request count
     - Target response time
     - Healthy host count
     - HTTP response codes

2. **Target Group Health:**
   - Return to EC2 → Target Groups
   - Monitor health status of all target groups
   - Check health check details

---

## Advanced Exercises (Optional)

### Exercise 1: Implement Sticky Sessions
1. **Modify Target Group:**
   - Select `USERNAME-web-tg`
   - **Actions** → **Edit attributes**
   - Enable **Stickiness**
   - **Stickiness type:** Load balancer generated cookie
   - **Stickiness duration:** 300 seconds

2. **Test Stickiness:**
   - Use browser to test session persistence
   - Use curl with cookie jar to verify

### Exercise 2: Configure Health Check Tuning
1. **Customize Health Checks:**
   - Modify health check intervals
   - Test different healthy/unhealthy thresholds
   - Observe failover behavior

2. **Simulate Server Failure:**
   - Stop httpd service on one server:
   ```bash
   sudo systemctl stop httpd
   ```
   - Monitor automatic traffic redirection

### Exercise 3: SSL/TLS Termination (Advanced)
1. **Request SSL Certificate:**
   - Use AWS Certificate Manager (ACM)
   - Request certificate for a domain (if available)

2. **Add HTTPS Listener:**
   - Add listener on port 443
   - Configure SSL certificate
   - Test HTTPS connectivity

---

## Troubleshooting

### Common Issues and Solutions

**Issue: Targets showing unhealthy**
- **Solution:** Check security group rules allow traffic from ALB
- **Verify:** Health check path returns 200 status code
- **Check:** Instance status and application logs

**Issue: 502 Bad Gateway errors**
- **Solution:** Verify target applications are running
- **Check:** Security group allows ALB to reach targets
- **Verify:** Target group health check configuration

**Issue: Traffic not distributing evenly**
- **Solution:** Check target weights in target group
- **Verify:** Both targets are healthy
- **Consider:** Connection draining settings

**Issue: Path-based routing not working**
- **Solution:** Verify listener rule priority and conditions
- **Check:** Rules are in correct order (lower priority first)
- **Verify:** Path patterns match expected URLs

---

## Cleanup Instructions

**⚠️ Important:** Clean up resources to avoid charges

### Step 1: Delete Load Balancer
1. **Delete ALB:**
   - Go to **Load Balancers**
   - Select your ALB (USERNAME-web-alb)
   - **Actions** → **Delete load balancer**
   - Confirm deletion

### Step 2: Delete Target Groups
1. **Delete Target Groups:**
   - Go to **Target Groups**
   - Select all target groups (USERNAME-web-tg, USERNAME-app-tg, USERNAME-api-tg)
   - **Actions** → **Delete**
   - Confirm deletion

### Step 3: Terminate Instances
1. **Terminate Web Servers:**
   - Go to **Instances**
   - Select both web servers (USERNAME-web-server-1, USERNAME-web-server-2)
   - **Instance State** → **Terminate instance**
   - Confirm termination

### Step 4: Delete Security Groups
1. **Delete Custom Security Groups:**
   - Go to **Security Groups**
   - Delete `USERNAME-alb-sg` and `USERNAME-web-sg`
   - **Actions** → **Delete security group**

---

## Key Concepts Learned

1. **Application Load Balancer Architecture:**
   - Layer 7 load balancing capabilities
   - Target group concepts and health checks
   - Multi-AZ deployment for high availability

2. **Routing and Traffic Management:**
   - Path-based routing configurations
   - Listener rules and priorities
   - Traffic distribution algorithms

3. **Health Monitoring:**
   - Health check configuration and tuning
   - Automatic failover mechanisms
   - CloudWatch integration for monitoring

4. **Security and Network Integration:**
   - Security group configurations for ALB
   - VPC integration and subnet selection
   - SSL termination capabilities

---

## Validation Checklist

- [ ] Successfully created Application Load Balancer in public subnets
- [ ] Configured target groups with proper health checks
- [ ] Registered multiple instances across different AZs
- [ ] Verified load balancing across healthy targets
- [ ] Implemented path-based routing rules
- [ ] Tested different routing paths (/app, /api, /health)
- [ ] Monitored ALB metrics in CloudWatch
- [ ] Observed automatic failover during instance failure
- [ ] Cleaned up all resources properly

---

## Next Steps

- **Lab 9:** Auto Scaling Implementation
- **Advanced Topics:** SSL certificate management, WAF integration
- **Real-world Applications:** Blue-green deployments, canary releases

---

**Lab Duration:** 45 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Lab 4 (VPC Networking) completion

