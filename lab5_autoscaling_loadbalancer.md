# Lab 5: Auto Scaling & Load Balancing
## Build Scalable Web Infrastructure

**Duration:** 75 minutes  
**Prerequisites:** Completed Lab 2 (VPC Configuration) or have a VPC with public and private subnets

### Learning Objectives
By the end of this lab, you will be able to:
- Create launch templates for standardized EC2 instance deployment
- Configure Auto Scaling groups for automatic capacity management
- Set up Application Load Balancer with target groups
- Implement scaling policies based on CloudWatch metrics
- Test high availability by simulating instance failures
- Monitor application performance and scaling events
- Understand load balancing algorithms and health checks

### Architecture Overview
You will build a scalable web application architecture with an Application Load Balancer distributing traffic across multiple EC2 instances managed by an Auto Scaling group. The infrastructure will automatically scale based on CPU utilization and maintain high availability across multiple Availability Zones.

### Part 1: Prepare Your Environment

#### Step 1: Verify Prerequisites
1. Navigate to **VPC** service in AWS Management Console
2. Confirm you have:
   - A VPC with at least 2 public subnets in different AZs
   - Internet Gateway attached to the VPC
   - Route tables configured for public access
3. If you need to create these resources, refer back to Lab 2

#### Step 2: Create Security Groups
1. Navigate to **EC2** service
2. Click **Security Groups** in the left navigation menu
3. Create **Load Balancer Security Group:**
   - **Name:** `ALB-SecurityGroup`
   - **Description:** `Security group for Application Load Balancer`
   - **VPC:** Select your VPC
   - **Inbound rules:**
     - Type: HTTP, Port: 80, Source: 0.0.0.0/0
     - Type: HTTPS, Port: 443, Source: 0.0.0.0/0
   - Click **Create security group**

4. Create **Web Server Security Group:**
   - **Name:** `WebServer-SecurityGroup`
   - **Description:** `Security group for web server instances`
   - **VPC:** Select your VPC
   - **Inbound rules:**
     - Type: HTTP, Port: 80, Source: Custom, Source value: `ALB-SecurityGroup` (select from dropdown)
     - Type: SSH, Port: 22, Source: My IP
   - Click **Create security group**

### Part 2: Create Launch Template

#### Step 1: Navigate to Launch Templates
1. In EC2 service, click **Launch Templates** in the left navigation menu
2. Click **Create launch template**

#### Step 2: Configure Launch Template
1. **Launch template name:** `WebServer-LaunchTemplate`
2. **Template version description:** `Web server template for auto scaling`
3. **Application and OS Images (AMI):**
   - **Quick Start:** Amazon Linux
   - **Amazon Machine Image:** Amazon Linux 2023 AMI (HVM)
4. **Instance type:** t2.micro (or t3.micro if available)
5. **Key pair:** Select an existing key pair or create new one
6. **Network settings:**
   - **Security groups:** Select `WebServer-SecurityGroup`
7. **Advanced details:**
   - **IAM instance profile:** Leave blank
   - **User data:** Enter the following script:
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
   
   # Create a simple web page
   cat > /var/www/html/index.html << EOF
   <!DOCTYPE html>
   <html>
   <head>
       <title>Auto Scaling Demo</title>
       <style>
           body { font-family: Arial, sans-serif; margin: 40px; background-color: #f0f8ff; }
           .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
           .header { background-color: #232f3e; color: white; padding: 20px; text-align: center; border-radius: 5px; margin-bottom: 20px; }
           .aws-orange { color: #ff9900; }
           .info-box { background-color: #e7f3ff; padding: 15px; border-left: 4px solid #007acc; margin: 10px 0; }
           .button { background-color: #ff9900; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; margin: 5px; }
           .button:hover { background-color: #e88600; }
       </style>
   </head>
   <body>
       <div class="container">
           <div class="header">
               <h1>🚀 AWS Auto Scaling Demo</h1>
               <p>Load Balanced Web Application</p>
           </div>
           
           <h2>Instance Information</h2>
           <div class="info-box">
               <strong>Instance ID:</strong> $INSTANCE_ID<br>
               <strong>Availability Zone:</strong> $AZ<br>
               <strong>Private IP:</strong> $PRIVATE_IP<br>
               <strong>Server Time:</strong> <span id="time"></span>
           </div>
           
           <h2>Load Testing</h2>
           <p>Use these buttons to simulate load and test auto scaling:</p>
           <button class="button" onclick="generateLoad()">Generate CPU Load (30 seconds)</button>
           <button class="button" onclick="stopLoad()">Stop Load</button>
           
           <h2>Auto Scaling Features</h2>
           <ul>
               <li>Automatic instance launch and termination</li>
               <li>Load balancing across multiple AZs</li>
               <li>Health checks and automatic replacement</li>
               <li>Scaling based on CloudWatch metrics</li>
           </ul>
           
           <div id="loadStatus"></div>
       </div>
       
       <script>
           function updateTime() {
               document.getElementById('time').textContent = new Date().toLocaleString();
           }
           setInterval(updateTime, 1000);
           updateTime();
           
           function generateLoad() {
               document.getElementById('loadStatus').innerHTML = '<div class="info-box">⚡ Generating CPU load for 30 seconds...</div>';
               fetch('/load')
                   .then(response => response.text())
                   .then(data => {
                       document.getElementById('loadStatus').innerHTML = '<div class="info-box">✅ Load generation completed</div>';
                   });
           }
           
           function stopLoad() {
               fetch('/stop')
                   .then(response => response.text())
                   .then(data => {
                       document.getElementById('loadStatus').innerHTML = '<div class="info-box">🛑 Load generation stopped</div>';
                   });
           }
       </script>
   </body>
   </html>
   EOF
   
   # Create CGI script for load generation
   cat > /var/www/cgi-bin/load << 'EOF'
   #!/bin/bash
   echo "Content-Type: text/plain"
   echo ""
   
   # Generate CPU load for 30 seconds
   stress --cpu 2 --timeout 30s &
   echo "Load generation started for 30 seconds"
   EOF
   
   cat > /var/www/cgi-bin/stop << 'EOF'
   #!/bin/bash
   echo "Content-Type: text/plain"
   echo ""
   
   # Stop all stress processes
   pkill stress
   echo "Load generation stopped"
   EOF
   
   chmod +x /var/www/cgi-bin/load
   chmod +x /var/www/cgi-bin/stop
   
   # Configure Apache for CGI
   echo "LoadModule cgi_module modules/mod_cgi.so" >> /etc/httpd/conf/httpd.conf
   echo "ScriptAlias /load /var/www/cgi-bin/load" >> /etc/httpd/conf/httpd.conf
   echo "ScriptAlias /stop /var/www/cgi-bin/stop" >> /etc/httpd/conf/httpd.conf
   systemctl restart httpd
   ```

8. Click **Create launch template**

### Part 3: Create Application Load Balancer

#### Step 1: Navigate to Load Balancers
1. In EC2 service, click **Load Balancers** in the left navigation menu
2. Click **Create Load Balancer**

#### Step 2: Configure Load Balancer
1. **Load balancer types:** Select **Application Load Balancer**
2. **Basic configuration:**
   - **Load balancer name:** `WebApp-ALB`
   - **Scheme:** Internet-facing
   - **IP address type:** IPv4
3. **Network mapping:**
   - **VPC:** Select your VPC
   - **Mappings:** Select at least 2 Availability Zones and their public subnets
4. **Security groups:**
   - Remove default security group
   - Select `ALB-SecurityGroup`
5. **Listeners and routing:**
   - **Protocol:** HTTP
   - **Port:** 80
   - **Default action:** We'll create target group in next step

#### Step 3: Create Target Group
1. Click **Create target group** (opens in new tab)
2. **Basic configuration:**
   - **Target type:** Instances
   - **Target group name:** `WebServers-TG`
   - **Protocol:** HTTP
   - **Port:** 80
   - **VPC:** Select your VPC
3. **Health checks:**
   - **Health check protocol:** HTTP
   - **Health check path:** /
   - **Advanced health check settings:**
     - **Healthy threshold:** 2
     - **Unhealthy threshold:** 2
     - **Timeout:** 5 seconds
     - **Interval:** 30 seconds
     - **Success codes:** 200
4. Click **Next**
5. **Register targets:** Skip this step (Auto Scaling will handle this)
6. Click **Create target group**

#### Step 4: Complete Load Balancer Setup
1. Return to the Load Balancer creation tab
2. **Default action:** Select `WebServers-TG` from dropdown
3. Click **Create load balancer**
4. Wait for the load balancer to become **Active** (3-5 minutes)

### Part 4: Create Auto Scaling Group

#### Step 1: Navigate to Auto Scaling Groups
1. In EC2 service, click **Auto Scaling Groups** in the left navigation menu
2. Click **Create Auto Scaling group**

#### Step 2: Configure Auto Scaling Group
1. **Step 1: Choose launch template**
   - **Auto Scaling group name:** `WebServers-ASG`
   - **Launch template:** Select `WebServer-LaunchTemplate`
   - **Version:** Latest
   - Click **Next**

2. **Step 2: Choose instance launch options**
   - **VPC:** Select your VPC
   - **Availability Zones and subnets:** Select your public subnets (at least 2 AZs)
   - Click **Next**

3. **Step 3: Configure advanced options**
   - **Load balancing:** Enable load balancing
   - **Application Load Balancer target groups:** Select `WebServers-TG`
   - **Health checks:**
     - **Health check type:** ELB
     - **Health check grace period:** 300 seconds
   - **Additional settings:**
     - **Enable group metrics collection:** Check this box
   - Click **Next**

4. **Step 4: Configure group size and scaling policies**
   - **Group size:**
     - **Desired capacity:** 2
     - **Minimum capacity:** 1
     - **Maximum capacity:** 4
   - **Scaling policies:** Target tracking scaling policy
     - **Policy name:** `CPU-ScalingPolicy`
     - **Metric type:** Average CPU utilization
     - **Target value:** 50
     - **Instance warmup:** 300 seconds
   - Click **Next**

5. **Step 5: Add notifications (Optional)**
   - Skip or configure if desired
   - Click **Next**

6. **Step 6: Add tags**
   - **Key:** Name, **Value:** WebServer-ASG-Instance
   - Click **Next**

7. **Step 7: Review**
   - Review all settings
   - Click **Create Auto Scaling group**

### Part 5: Test the Application

#### Step 1: Access the Application
1. Navigate to **Load Balancers** in EC2 console
2. Select `WebApp-ALB`
3. Copy the **DNS name** from the Details tab
4. Open a web browser and navigate to: `http://[ALB-DNS-NAME]`
5. You should see the Auto Scaling Demo page with instance information

#### Step 2: Verify Load Balancing
1. Refresh the page multiple times
2. Notice the **Instance ID** and **Availability Zone** may change
3. This demonstrates traffic distribution across instances

#### Step 3: Check Auto Scaling Group Status
1. Navigate to **Auto Scaling Groups**
2. Select `WebServers-ASG`
3. **Activity** tab: View scaling activities
4. **Instance management** tab: See running instances
5. **Monitoring** tab: View CloudWatch metrics

### Part 6: Test High Availability

#### Step 1: Simulate Instance Failure
1. Navigate to **EC2 Instances**
2. Find instances with names starting with `WebServer-ASG-Instance`
3. Select one instance
4. Click **Actions** → **Instance State** → **Terminate**
5. Confirm termination

#### Step 2: Observe Auto Recovery
1. Return to **Auto Scaling Groups** → `WebServers-ASG`
2. **Activity** tab: Watch for replacement instance launch
3. **Instance management** tab: See new instance being created
4. Test the application URL again to ensure it's still accessible

#### Step 3: Monitor Health Checks
1. Navigate to **Target Groups** → `WebServers-TG`
2. **Targets** tab: Observe health status of instances
3. Watch as terminated instance becomes unhealthy and is removed
4. New instance should appear and become healthy

### Part 7: Test Auto Scaling

#### Step 1: Generate Load
1. Access your application in the browser
2. Click **Generate CPU Load (30 seconds)** button multiple times
3. This simulates high CPU usage on the instance

#### Step 2: Monitor Scaling Activity
1. Navigate to **Auto Scaling Groups** → `WebServers-ASG`
2. **Activity** tab: Watch for scale-out activities
3. **Monitoring** tab: Check CPU utilization metrics
4. Wait 5-10 minutes for scaling to trigger (based on 50% CPU threshold)

#### Step 3: Observe Scale-Out
1. **Instance management** tab: Should show additional instances launching
2. Navigate to **Target Groups** → `WebServers-TG`
3. **Targets** tab: New instances should appear and become healthy
4. Test the application - more instances should be serving traffic

#### Step 4: Test Scale-In
1. Stop generating load by clicking **Stop Load** button
2. Wait 10-15 minutes for CPU to normalize
3. Auto Scaling should terminate excess instances to meet desired capacity

### Part 8: Advanced Load Balancer Features

#### Step 1: Configure Sticky Sessions (Optional)
1. Navigate to **Target Groups** → `WebServers-TG`
2. **Attributes** tab → **Edit**
3. **Stickiness:** Enable
4. **Stickiness type:** Load balancer generated cookie
5. **Stickiness duration:** 1 hour
6. **Save changes**

#### Step 2: Test Different Routing (Optional)
1. Create a new target group for demonstration
2. Configure listener rules for path-based routing
3. Example: Route `/api/*` to different target group

### Part 9: Monitor and Troubleshoot

#### Step 1: CloudWatch Metrics
1. Navigate to **CloudWatch** service
2. **Metrics** → **EC2** → **By Auto Scaling Group**
3. Select metrics for `WebServers-ASG`:
   - GroupDesiredCapacity
   - GroupInServiceInstances
   - GroupTotalInstances
4. **Application Load Balancer** metrics:
   - RequestCount
   - TargetResponseTime
   - HealthyHostCount

#### Step 2: View Scaling History
1. Auto Scaling Groups → `WebServers-ASG`
2. **Activity** tab: Review all scaling activities
3. **Scaling policies** tab: Check policy configuration and history

#### Step 3: Load Balancer Access Logs (Optional)
1. Navigate to **Load Balancers** → `WebApp-ALB`
2. **Attributes** tab → **Edit**
3. **Access logs:** Enable
4. **S3 location:** Create or select S3 bucket
5. **Save changes**

### Part 10: Performance Testing

#### Step 1: Install Load Testing Tool
1. Connect to one of your instances via SSH
2. Install Apache Bench:
   ```bash
   sudo yum install -y httpd-tools
   ```

#### Step 2: Run Load Test
1. Test single instance performance:
   ```bash
   ab -n 1000 -c 10 http://[ALB-DNS-NAME]/
   ```
2. Analyze results: requests per second, response times

#### Step 3: Monitor During Load Test
1. Watch CloudWatch metrics in real-time
2. Observe Auto Scaling behavior during sustained load
3. Check load balancer request distribution

### Part 11: Cleanup Resources

⚠️ **Important:** Clean up all resources to avoid charges

#### Step 1: Delete Auto Scaling Group
1. Navigate to **Auto Scaling Groups**
2. Select `WebServers-ASG`
3. **Actions** → **Delete**
4. Type "delete" and confirm
5. Wait for all instances to terminate

#### Step 2: Delete Load Balancer
1. Navigate to **Load Balancers**
2. Select `WebApp-ALB`
3. **Actions** → **Delete load balancer**
4. Type "confirm" and delete

#### Step 3: Delete Target Group
1. Navigate to **Target Groups**
2. Select `WebServers-TG`
3. **Actions** → **Delete**
4. Confirm deletion

#### Step 4: Delete Launch Template
1. Navigate to **Launch Templates**
2. Select `WebServer-LaunchTemplate`
3. **Actions** → **Delete template**
4. Confirm deletion

#### Step 5: Delete Security Groups
1. Navigate to **Security Groups**
2. Delete `WebServer-SecurityGroup`
3. Delete `ALB-SecurityGroup`

### Key Concepts Learned

**Auto Scaling:**
- Launch templates define instance configuration
- Auto Scaling groups manage instance lifecycle
- Scaling policies respond to CloudWatch metrics
- Health checks ensure application availability

**Load Balancing:**
- Application Load Balancer operates at Layer 7
- Target groups organize and health check targets
- Multiple routing algorithms available
- Integration with Auto Scaling for dynamic targets

**High Availability:**
- Multi-AZ deployment prevents single points of failure
- Automatic instance replacement on failure
- Health checks at multiple levels (instance, application)
- Load distribution across availability zones

**Monitoring and Optimization:**
- CloudWatch metrics for scaling decisions
- Access logs for traffic analysis
- Performance testing for capacity planning
- Cost optimization through appropriate scaling

### Troubleshooting Tips

**Instances not launching:**
- Check launch template configuration
- Verify security group allows required traffic
- Ensure subnets have available IP addresses
- Check service limits for EC2 instances

**Load balancer showing unhealthy targets:**
- Verify security group allows traffic from load balancer
- Check health check path returns 200 status
- Ensure web server is running on instances
- Verify health check timeout and interval settings

**Auto Scaling not working:**
- Check CloudWatch metrics are being published
- Verify scaling policy thresholds are appropriate
- Ensure sufficient time for warmup periods
- Check service limits haven't been reached

**Application not accessible:**
- Verify load balancer security group allows inbound traffic
- Check route table configuration for public subnets
- Ensure Internet Gateway is attached and configured
- Verify DNS resolution of load balancer endpoint

### Next Steps
This completes the core infrastructure labs. You now have experience with:
- Networking (VPC, subnets, routing)
- Compute (EC2, Auto Scaling)
- Storage (S3, EBS)
- Databases (RDS)
- Load Balancing (Application Load Balancer)

These components form the foundation for building scalable, highly available applications on AWS. In production environments, you would also implement monitoring, logging, security hardening, and disaster recovery procedures.