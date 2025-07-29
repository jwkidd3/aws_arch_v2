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
   - Click **Launch instances**
   - **Name:** `USERNAME-web-server-1` ⚠️ **Replace USERNAME with your assigned username**
   - **AMI:** Amazon Linux 2023 AMI
   - **Instance type:** t3.micro
   - **Key pair:** Select existing key pair or create new one
   - **Network settings:**
     - **VPC:** Select your custom VPC (MyProdVPC)
     - **Subnet:** Select private subnet in first AZ (private-subnet-a)
     - **Auto-assign public IP:** Disable
   - **Security group:** Create new security group
     - **Name:** `USERNAME-web-sg` ⚠️ **Replace USERNAME with your assigned username**
     - **Rules:**
       - HTTP (80) from VPC CIDR (10.0.0.0/16)
       - SSH (22) from VPC CIDR (10.0.0.0/16)

3. **User Data Script:**
   Add the following script in **Advanced details** → **User data**:
   ```bash
   #!/bin/bash
   yum update -y
   yum install -y httpd
   systemctl start httpd
   systemctl enable httpd
   
   # Create different application endpoints
   echo "<h1>Web Server 1 - Main Page</h1><p>Server: $(hostname)</p><p>IP: $(hostname -I)</p>" > /var/www/html/index.html
   echo "<h1>Application Tier</h1><p>Server: $(hostname)</p><p>Time: $(date)</p>" > /var/www/html/app/index.html
   echo "<h1>API Tier</h1><p>Server: $(hostname)</p><p>Status: Active</p>" > /var/www/html/api/index.html
   echo "OK" > /var/www/html/health
   
   # Create directories
   mkdir -p /var/www/html/app
   mkdir -p /var/www/html/api
   
   # Set proper permissions
   chown -R apache:apache /var/www/html
   chmod -R 755 /var/www/html
   ```

4. **Launch Second Web Server:**
   - Repeat the same process for the second server
   - **Name:** `USERNAME-web-server-2` ⚠️ **Replace USERNAME with your assigned username**
   - **Subnet:** Select private subnet in second AZ (private-subnet-b)
   - **Security group:** Use existing `USERNAME-web-sg`
   - Use the same user data script, but change "Web Server 1" to "Web Server 2"

5. **Verify Instance Status:**
   - Both instances should be in "running" state
   - Status checks should be "2/2 checks passed"
   - Note the private IP addresses of both instances

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

7. **Review and Create:**
   - Review all settings
   - Click **Create load balancer**
   - Wait for ALB to become "Active" (2-3 minutes)

---

## Task 3: Configure Advanced Routing and Test Load Balancing (10 minutes)

### Step 1: Create Additional Target Groups
1. **Create App Target Group:**
   - **Name:** `USERNAME-app-tg` ⚠️ **Replace USERNAME with your assigned username**
   - **Health check path:** `/app/`
   - Register both instances

2. **Create API Target Group:**
   - **Name:** `USERNAME-api-tg` ⚠️ **Replace USERNAME with your assigned username**
   - **Health check path:** `/api/`
   - Register both instances

### Step 2: Configure Path-Based Routing
1. **Edit ALB Listener:**
   - Select your ALB
   - Go to **Listeners** tab
   - Select the HTTP:80 listener
   - Click **View/edit rules**

2. **Add Routing Rules:**
   - Click **+** to add rules
   - **Rule 1:**
     - **IF:** Path is `/app*`
     - **THEN:** Forward to `USERNAME-app-tg`
     - **Priority:** 100
   - **Rule 2:**
     - **IF:** Path is `/api*`
     - **THEN:** Forward to `USERNAME-api-tg`
     - **Priority:** 200

### Step 3: Test Load Balancing
1. **Get ALB DNS Name:**
   - Copy the DNS name from ALB details
   - Example: `USERNAME-web-alb-1234567890.us-east-1.elb.amazonaws.com`

2. **Test Default Route:**
   ```bash
   curl http://ALB_DNS_NAME/
   # Should alternate between Server 1 and Server 2
   ```

3. **Test Path-Based Routing:**
   ```bash
   curl http://ALB_DNS_NAME/app/
   curl http://ALB_DNS_NAME/api/
   curl http://ALB_DNS_NAME/health
   ```

4. **Test in Browser:**
   - Open ALB DNS name in browser
   - Refresh multiple times to see load balancing
   - Test /app and /api paths

---

## Cleanup Instructions

### Step 1: Delete ALB
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

