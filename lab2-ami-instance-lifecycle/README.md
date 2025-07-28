# Lab 2: AMI Creation & Instance Lifecycle

**Duration:** 45 minutes  
**Objective:** Master EC2 instance lifecycle management, AMI creation workflows, and understand the differences between user data and AMI approaches for instance configuration.

## Prerequisites
- Completion of Lab 1: EC2 Basics & Instance Management
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Understand the complete EC2 instance lifecycle
- Create and manage custom AMIs efficiently
- Compare user data vs AMI approaches for configuration
- Implement proper AMI versioning and management
- Troubleshoot common AMI-related issues
- Understand instance state transitions and billing implications

---

## Task 1: Advanced Instance Lifecycle Management (15 minutes)

### Step 1: Launch Base Instance with Advanced Configuration
1. **Navigate to EC2:**
   - In the AWS Management Console, go to **EC2** service
   - Click **Instances** in the left navigation menu

2. **Launch Instance with Enhanced Settings:**
   - Click **Launch Instances**
   - **Name:** `USERNAME-lifecycle-base` ⚠️ **Replace USERNAME with your assigned username**
   - **AMI:** Amazon Linux 2023 AMI
   - **Instance type:** t2.micro
   - **Key pair:** Use existing `USERNAME-keypair` from Lab 1 (or create new one) ⚠️ **Use your username**

3. **Advanced Network Configuration:**
   - **VPC:** Default VPC
   - **Subnet:** Any available public subnet
   - **Auto-assign public IP:** Enable
   - **Security group:** Create new `USERNAME-lifecycle-sg` ⚠️ **Replace USERNAME with your assigned username**
   - **Rules:**
     - SSH (22) from 0.0.0.0/0
     - HTTP (80) from 0.0.0.0/0
     - HTTPS (443) from 0.0.0.0/0

4. **User Data Script:**
```bash
#!/bin/bash
set -euxo pipefail

# Update and install Apache only (no curl install)
yum update -y
yum install -y httpd

# Enable CGI support in Apache
sed -i 's/^#\(AddHandler cgi-script .cgi\)/\1/' /etc/httpd/conf/httpd.conf
sed -i '/<Directory "\/var\/www\/cgi-bin">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
sed -i '/<Directory "\/var\/www\/cgi-bin">/,/<\/Directory>/ s/Options None/Options +ExecCGI/' /etc/httpd/conf/httpd.conf

# Start and enable Apache
systemctl enable httpd
systemctl start httpd

# Create a version info file
echo "Base Instance - $(date)" > /var/www/html/version.txt

# Create a static HTML system info page
cat > /var/www/html/sysinfo.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>System Information - USERNAME Instance</title>
</head>
<body>
    <h1>System Information</h1>
    <ul>
        <li><a href="/version.txt">Version Info</a></li>
        <li><a href="/cgi-bin/instance-metadata.sh">Instance Metadata</a></li>
    </ul>
</body>
</html>
HTML

# Create IMDSv2-compatible CGI script for live instance metadata
cat > /var/www/cgi-bin/instance-metadata.sh << 'EOF'
#!/bin/bash
echo "Content-Type: text/html"
echo ""

echo "<html><body><h2>Instance Metadata (IMDSv2)</h2><pre>"

TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

echo "Instance ID: $(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)"
echo
echo "Instance Type: $(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type)"
echo
echo "Public IP: $(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)"
echo
echo "Private IP: $(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)"
echo
echo "Availability Zone: $(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)"
echo "</pre></body></html>"
EOF

# Ensure CGI script is executable
chmod +x /var/www/cgi-bin/instance-metadata.sh

# Log completion
echo "User data script completed at $(date)" >> /var/log/userdata.log
```

5. **Launch the Instance:**
   - Review all settings
   - Click **Launch instance**

### Step 2: Monitor Instance Lifecycle States
1. **Track Instance States:**
   - Watch the instance progress through states: `pending` → `running`
   - Note the **Status Checks** progression
   - Document the time taken for each state transition

2. **Test Instance Functionality:**
   - Once in `running` state, test SSH connectivity
   - Verify web server: `http://YOUR_PUBLIC_IP/sysinfo.html`
   - Check version endpoint: `http://YOUR_PUBLIC_IP/version.txt`

3. **Instance State Experiments:**
   ```bash
   # Connect to instance and run system commands
   sudo systemctl status httpd
   df -h
   free -m
   uptime
   cat /var/log/userdata.log
   ```

---

## Task 2: AMI Creation and Versioning (20 minutes)

### Step 1: Create First Generation AMI
1. **Prepare Instance for AMI Creation:**
   - Connect to your instance via SSH or EC2 Instance Connect
   - Make additional customizations:
   ```bash
   # Install additional tools
   sudo yum install -y wget curl vim nano tree
   
   # Create custom application directory
   sudo mkdir -p /opt/myapp
   sudo chown ec2-user:ec2-user /opt/myapp
   
   # Create application script
   cat > /opt/myapp/status.sh << 'SCRIPT'
   #!/bin/bash
   echo "=== Application Status ==="
   echo "Version: 1.0"
   echo "Owner: USERNAME"
   echo "Last Updated: $(date)"
   echo "System Uptime: $(uptime)"
   echo "Disk Usage:"
   df -h | grep -E "/$|/opt"
   SCRIPT
   
   chmod +x /opt/myapp/status.sh
   
   # Update web content
   sudo tee /var/www/html/index.html > /dev/null << 'HTML'
   <!DOCTYPE html>
   <html>
   <head>
       <title>USERNAME - AMI v1.0</title>
       <style>
           body { font-family: Arial, sans-serif; text-align: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; margin: 0; padding: 50px; }
           .container { background: rgba(255,255,255,0.1); padding: 40px; border-radius: 15px; backdrop-filter: blur(10px); display: inline-block; }
           .version { background: rgba(255,255,255,0.2); padding: 10px; border-radius: 5px; margin: 20px 0; }
       </style>
   </head>
   <body>
       <div class="container">
           <h1>🚀 Custom AMI Application</h1>
           <h2>Created by: USERNAME</h2>
           <div class="version">
               <h3>AMI Version: 1.0</h3>
               <p>Base configuration with web server and custom tools</p>
           </div>
           <p>This instance was launched from a custom AMI</p>
           <p><a href="/sysinfo.html" style="color: #ffeb3b;">System Information</a></p>
       </div>
   </body>
   </html>
HTML
   
   # Clear bash history for clean AMI
   history -c
   ```

2. **Create AMI v1.0:**
   - In EC2 Console, select your instance
   - **Actions** → **Image and templates** → **Create image**
   - **Image name:** `USERNAME-custom-ami-v1.0` ⚠️ **Replace USERNAME with your assigned username**
   - **Image description:** `Custom AMI v1.0 - Web server with development tools`
   - **No reboot:** Leave unchecked (recommended for consistency)
   - Click **Create image**

3. **Monitor AMI Creation:**
   - Go to **AMIs** in the left navigation
   - Watch the status progress: `pending` → `available`
   - Note the AMI ID and creation time

### Step 2: Test AMI v1.0
1. **Launch Instance from Custom AMI:**
   - In **AMIs** section, select your AMI `USERNAME-custom-ami-v1.0`
   - Click **Launch instance from AMI**
   - **Name:** `USERNAME-ami-test-v1` ⚠️ **Replace USERNAME with your assigned username**
   - **Instance type:** t2.micro
   - **Key pair:** Use existing `USERNAME-keypair` ⚠️ **Use your username**
   - **Security group:** Use existing `USERNAME-lifecycle-sg` ⚠️ **Use your username**
   - **Auto-assign public IP:** Enable

2. **Verify AMI Persistence:**
   - Wait for instance to reach `running` state
   - Test web interface: `http://NEW_INSTANCE_PUBLIC_IP`
   - SSH to instance and verify:
   ```bash
   # Check if custom configurations persist
   ls -la /opt/myapp/
   /opt/myapp/status.sh
   sudo systemctl status httpd
   which tree vim nano
   ```

### Step 3: Create Enhanced AMI v2.0
1. **Enhance the Original Instance:**
   - Connect to your original instance (`USERNAME-lifecycle-base`)
   - Add more functionality:
   ```bash
   # Install monitoring tools
   sudo yum install -y htop iotop nethogs
   
   # Create monitoring dashboard
   sudo mkdir -p /var/www/html/monitoring
   
   sudo tee /var/www/html/monitoring/index.html > /dev/null << 'HTML'
   <!DOCTYPE html>
   <html>
   <head>
       <title>Monitoring Dashboard - USERNAME</title>
       <meta http-equiv="refresh" content="30">
       <style>
           body { font-family: 'Courier New', monospace; background: #1a1a1a; color: #00ff00; margin: 20px; }
           .monitor-box { background: #2a2a2a; border: 1px solid #00ff00; padding: 15px; margin: 10px 0; border-radius: 5px; }
           pre { margin: 0; overflow-x: auto; }
       </style>
   </head>
   <body>
       <h1>🖥️ Real-time System Monitor</h1>
       <div class="monitor-box">
           <h3>System Load</h3>
           <pre id="load"></pre>
       </div>
       <div class="monitor-box">
           <h3>Memory Usage</h3>
           <pre id="memory"></pre>
       </div>
       <div class="monitor-box">
           <h3>Disk Usage</h3>
           <pre id="disk"></pre>
       </div>
       <script>
           function updateStats() {
               // This would typically fetch real data via AJAX
               document.getElementById('load').innerHTML = 'Load: Simulated real-time data\nUptime: ' + Date.now();
           }
           setInterval(updateStats, 5000);
           updateStats();
       </script>
   </body>
   </html>
HTML
   
   # Update version info
   echo "Enhanced Instance v2.0 - $(date)" | sudo tee /var/www/html/version.txt
   
   # Create backup script
   sudo tee /opt/myapp/backup.sh > /dev/null << 'SCRIPT'
   #!/bin/bash
   BACKUP_DIR="/opt/myapp/backups"
   mkdir -p $BACKUP_DIR
   
   echo "Creating backup at $(date)"
   tar -czf $BACKUP_DIR/config-backup-$(date +%Y%m%d-%H%M%S).tar.gz /etc/httpd/ /var/www/html/
   echo "Backup completed"
   
   # Keep only last 5 backups
   ls -t $BACKUP_DIR/*.tar.gz | tail -n +6 | xargs -r rm
SCRIPT
   
   chmod +x /opt/myapp/backup.sh
   
   # Update main page
   sudo sed -i 's/AMI Version: 1\.0/AMI Version: 2.0/g' /var/www/html/index.html
   sudo sed -i 's/Base configuration/Enhanced configuration with monitoring/g' /var/www/html/index.html
   ```

2. **Create AMI v2.0:**
   - **Actions** → **Image and templates** → **Create image**
   - **Image name:** `USERNAME-custom-ami-v2.0` ⚠️ **Replace USERNAME with your assigned username**
   - **Image description:** `Custom AMI v2.0 - Enhanced with monitoring and backup tools`
   - Click **Create image**

3. **Test AMI v2.0:**
   - Launch instance from AMI v2.0: `USERNAME-ami-test-v2` ⚠️ **Replace USERNAME with your assigned username**
   - Verify enhancements work correctly
   - Check monitoring dashboard: `http://PUBLIC_IP/monitoring/`

---

## Task 3: AMI Management and Comparison (10 minutes)

### Step 1: Compare User Data vs AMI Approaches
1. **Create User Data Equivalent Instance:**
   - Launch new instance: `USERNAME-userdata-comparison` ⚠️ **Replace USERNAME with your assigned username**
   - Use Amazon Linux 2023 AMI (base)
   - Use equivalent user data script to replicate AMI v2.0 functionality
   - Compare boot times and consistency

2. **Performance Analysis:**
   ```bash
   # Time the boot process for each approach
   # AMI-based instance boot time: [Record time]
   # User data instance boot time: [Record time]
   
   # Check for any differences in configuration
   diff -r /opt/myapp/ [between instances]
   ```

### Step 2: AMI Version Management
1. **List and Compare AMIs:**
   - In **AMIs** section, view both versions
   - Compare sizes, creation times, and descriptions
   - Note the relationship between AMIs and snapshots

2. **AMI Metadata Analysis:**
   ```bash
   # From any instance, check AMI information
   curl -s http://169.254.169.254/latest/meta-data/ami-id
   aws ec2 describe-images --image-ids YOUR_AMI_ID --region us-east-1
   ```

---

## Advanced Exercises (Optional)

### Exercise 1: AMI Automation
Create a script to automate AMI creation with proper naming conventions:

```bash
#!/bin/bash
# AMI automation script
INSTANCE_ID="i-xxxxxxxxx"  # Replace with your instance ID
AMI_NAME="USERNAME-auto-ami-$(date +%Y%m%d-%H%M%S)"
DESCRIPTION="Automated AMI creation on $(date)"

aws ec2 create-image \
    --instance-id $INSTANCE_ID \
    --name "$AMI_NAME" \
    --description "$DESCRIPTION" \
    --no-reboot \
    --region us-east-1
```

### Exercise 2: Cross-Region AMI Copy
Copy your AMI to another region:

```bash
# Copy AMI to us-west-2
aws ec2 copy-image \
    --source-region us-east-1 \
    --source-image-id YOUR_AMI_ID \
    --name "USERNAME-copied-ami" \
    --region us-west-2
```

---

## Cleanup Instructions

**⚠️ Important:** Clean up resources to avoid charges

### Step 1: Terminate All Test Instances
1. **Terminate Instances:**
   - `USERNAME-lifecycle-base`
   - `USERNAME-ami-test-v1`
   - `USERNAME-ami-test-v2`
   - `USERNAME-userdata-comparison`
   - Any other instances created during this lab

### Step 2: Clean Up AMIs and Snapshots
1. **Deregister AMIs:**
   - Go to **AMIs** section
   - Select `USERNAME-custom-ami-v1.0`
   - **Actions** → **Deregister AMI**
   - Confirm deregistration
   - Repeat for `USERNAME-custom-ami-v2.0`

2. **Delete Associated Snapshots:**
   - Go to **Snapshots** section
   - Find snapshots associated with your AMIs
   - Select and delete them
   - **Actions** → **Delete snapshot**

### Step 3: Clean Up Security Groups
1. **Delete Custom Security Group:**
   - Go to **Security Groups**
   - Select `USERNAME-lifecycle-sg`
   - **Actions** → **Delete security group**
   - Confirm deletion

---

## Troubleshooting

### Common Issues and Solutions

**Issue: AMI creation takes very long**
- **Solution:** Ensure instance is not under heavy load; consider using "No reboot" option carefully
- **Check:** Monitor CloudWatch metrics for disk activity

**Issue: Instance from AMI doesn't start properly**
- **Solution:** Check instance logs in EC2 console
- **Verify:** Security group settings and network configuration

**Issue: Custom applications don't work in new instance**
- **Solution:** Verify file permissions and service startup scripts
- **Check:** System logs: `/var/log/messages` and `/var/log/userdata.log`

**Issue: User data vs AMI inconsistencies**
- **Solution:** Ensure user data scripts are idempotent
- **Best Practice:** Use AMIs for stable configurations, user data for dynamic settings

---

## Key Concepts Learned

1. **Instance Lifecycle Management:**
   - Understanding instance states and transitions
   - Billing implications of different states
   - Proper shutdown and startup procedures

2. **AMI Creation Strategies:**
   - When to use AMIs vs user data
   - AMI versioning and management
   - Performance considerations

3. **Configuration Management:**
   - Persistent vs ephemeral configurations
   - Best practices for AMI preparation
   - Version control for infrastructure

4. **Cost Optimization:**
   - AMI storage costs vs compute costs
   - Regional considerations for AMI distribution
   - Lifecycle management for cost control

---

## Validation Checklist

- [ ] Successfully created and managed multiple AMI versions
- [ ] Launched instances from custom AMIs with all configurations intact
- [ ] Compared performance between AMI and user data approaches
- [ ] Understood instance lifecycle states and transitions
- [ ] Implemented proper AMI versioning and documentation
- [ ] Cleaned up all resources properly

---

## Next Steps

- **Lab 3:** IAM Configuration & Security
- **Advanced Topics:** Auto Scaling with custom AMIs, AMI sharing and permissions
- **Real-world Applications:** Blue-green deployments using AMIs

---

**Lab Duration:** 45 minutes  
**Difficulty:** Intermediate  
**Prerequisites:** Lab 1 completion, basic understanding of EC2

