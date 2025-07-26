#!/bin/bash

# Lab 1 Setup Script: EC2 Basics & Instance Management
# AWS Architecting Course - Day 1, Session 1
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
    print_header "AWS Architecting Course - Lab 1 Setup"
    print_status "Setting up EC2 Basics & Instance Management Lab"
    
    # Create lab directory structure
    LAB_DIR="lab1-ec2-basics"
    
    if [ -d "$LAB_DIR" ]; then
        print_warning "Directory $LAB_DIR already exists. Removing and recreating..."
        rm -rf "$LAB_DIR"
    fi
    
    mkdir -p "$LAB_DIR"
    cd "$LAB_DIR"
    
    print_status "Creating lab files in directory: $LAB_DIR"
    
    # Create README.md with lab instructions
    cat > README.md << 'EOF'
# Lab 1: EC2 Basics & Instance Management

**Duration:** 45 minutes  
**Objective:** Learn EC2 fundamentals including launching instances, configuring security groups, installing software, and creating AMIs.

## Prerequisites
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Launch EC2 instances using the AWS Management Console
- Configure security groups for web access
- Install and configure web server software
- Create custom AMIs for reuse
- Understand EC2 instance lifecycle management

---

## Task 1: Launch Your First EC2 Instance (15 minutes)

### Step 1: Access EC2 Service
1. **Navigate to EC2:**
   - In the AWS Management Console, search for "EC2" in the services search bar
   - Click on **EC2** to open the EC2 Dashboard

2. **Launch Instance:**
   - In the left navigation menu, click **Instances**
   - Click the **Launch Instances** button

### Step 2: Configure Instance Settings

**Modern AWS Console Note:** The EC2 launch process has been updated. Follow these steps in the new launch experience:

1. **Name and Tags:**
   - **Name:** `USERNAME-web-server` ⚠️ **Replace USERNAME with your assigned username**
   - This automatically creates a Name tag

2. **Application and OS Images (Amazon Machine Image):**
   - Select **Amazon Linux 2023 AMI** (or **Amazon Linux 2 AMI** if preferred)
   - Keep default settings

3. **Instance Type:**
   - Select **t2.micro** (Free tier eligible)

4. **Key Pair (login):**
   - Click **Create new key pair**
   - **Key pair name:** `USERNAME-keypair` ⚠️ **Replace USERNAME with your assigned username**
   - **Key pair type:** RSA
   - **Private key file format:** .pem
   - Click **Create key pair** and save it securely

5. **Network Settings:**
   - Click **Edit** to modify network settings
   - **VPC:** Leave as default
   - **Subnet:** Leave as default (or select any available)
   - **Auto-assign public IP:** **Enable**
   - **Firewall (security groups):** Select **Create security group**
   - **Security group name:** `USERNAME-web-sg` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** `Security group for web server`
   - **Security group rules:**
     - **Rule 1:** SSH, Port 22, Source: 0.0.0.0/0 (Anywhere)
     - Click **Add security group rule**
     - **Rule 2:** HTTP, Port 80, Source: 0.0.0.0/0 (Anywhere)

6. **Configure Storage:**
   - Keep default settings (8 GB gp3)

7. **Advanced Details:**
   - Leave all settings as default

8. **Review and Launch:**
   - Review your configuration in the **Summary** panel
   - Click **Launch instance**

### Step 3: Verify Instance Launch
- Click **View Instances** to see your launching instance
- Wait for **Instance State** to show "running"
- Note the **Public IPv4 address** for later use

---

## Task 2: Connect and Configure Web Server (20 minutes)

### Step 1: Connect to Your Instance
1. **Using EC2 Instance Connect:**
   - Select your instance in the EC2 console
   - Click **Connect**
   - Choose **EC2 Instance Connect**
   - Click **Connect**

### Step 2: Install and Configure Apache Web Server
Execute the following commands in your EC2 instance terminal:

```bash
# Update the system
sudo yum update -y

# Install Apache web server
sudo yum install -y httpd

# Start Apache service
sudo systemctl start httpd

# Enable Apache to start on boot
sudo systemctl enable httpd

# Check Apache status
sudo systemctl status httpd
```

### Step 3: Create a Custom Web Page
```bash
# Create a simple HTML page (copy and paste this entire block)
sudo tee /var/www/html/index.html > /dev/null << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>USERNAME Web Server</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            background-color: #f0f8ff;
            margin: 50px;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            display: inline-block;
        }
        h1 { color: #333; }
        .info { background-color: #e7f3ff; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Congratulations!</h1>
        <h2>Your EC2 Web Server is Running</h2>
        <div class="info">
            <p><strong>Instance Owner:</strong> USERNAME</p>
            <p><strong>Server:</strong> Apache on Amazon Linux 2</p>
            <p><strong>Lab:</strong> EC2 Basics & Instance Management</p>
        </div>
        <p>You have successfully:</p>
        <ul style="text-align: left; display: inline-block;">
            <li>Launched an EC2 instance</li>
            <li>Configured security groups</li>
            <li>Installed Apache web server</li>
            <li>Created a custom web page</li>
        </ul>
    </div>
</body>
</html>
HTML
```

⚠️ **Important:** After creating the file, replace the USERNAME placeholder with your assigned username:

```bash
# Replace USERNAME with your actual username (e.g., user1)
sudo sed -i "s/USERNAME/YOUR_USERNAME_HERE/g" /var/www/html/index.html

# Set proper permissions
sudo chown apache:apache /var/www/html/index.html
sudo chmod 644 /var/www/html/index.html
```

### Step 4: Test Your Web Server
1. **Get your instance's public IP:**
   - In EC2 console, note your instance's **Public IPv4 address**

2. **Test in browser:**
   - Open a web browser
   - Navigate to: `http://YOUR_PUBLIC_IP`
   - You should see your custom web page

3. **Test from command line:**
   ```bash
   # From within your EC2 instance
   curl http://localhost
   
   # Test external access (replace with your public IP)
   curl http://YOUR_PUBLIC_IP
   ```

---

## Task 3: Create Custom AMI (10 minutes)

### Step 1: Create AMI from Your Instance
1. **In EC2 Console:**
   - Select your running instance
   - Click **Actions** → **Image and templates** → **Create image**

2. **Configure AMI:**
   - **Image name:** `USERNAME-web-server-ami` ⚠️ **Replace USERNAME with your assigned username**
   - **Image description:** `Custom AMI with Apache web server pre-installed`
   - **No reboot:** Leave unchecked (recommended)
   - Click **Create image**

### Step 2: Monitor AMI Creation
1. **Check AMI status:**
   - In left navigation, click **AMIs**
   - Find your AMI and monitor its **Status**
   - Wait for status to change from "pending" to "available"

### Step 3: Launch Instance from Custom AMI
1. **Launch new instance:**
   - In AMIs section, select your custom AMI
   - Click **Launch instance from AMI**

2. **Quick configuration:**
   - **Instance type:** t2.micro
   - **Key pair:** Use existing `USERNAME-keypair` ⚠️ **Use your username**
   - **Security group:** Select existing `USERNAME-web-sg` ⚠️ **Use your username**
   - **Name tag:** `USERNAME-web-server-2` ⚠️ **Replace USERNAME with your assigned username**
   - Click **Launch instance**

### Step 4: Verify AMI Persistence
1. **Test new instance:**
   - Wait for new instance to reach "running" state
   - Get its public IP address
   - Test in browser: `http://NEW_INSTANCE_PUBLIC_IP`
   - Verify that Apache is running and your custom page appears

---

## Cleanup Instructions

**⚠️ Important:** Clean up resources to avoid charges

### Step 1: Terminate Instances
1. In EC2 Console, go to **Instances**
2. Select both instances (USERNAME-web-server and USERNAME-web-server-2)
3. **Actions** → **Instance State** → **Terminate instance**
4. Confirm termination

### Step 2: Delete AMI and Snapshots
1. **Delete AMI:**
   - Go to **AMIs** section
   - Select your custom AMI (USERNAME-web-server-ami)
   - **Actions** → **Deregister AMI**
   - Confirm deregistration

2. **Delete Snapshots:**
   - Go to **Snapshots** section
   - Find and select snapshots related to your AMI
   - **Actions** → **Delete snapshot**
   - Confirm deletion

### Step 3: Clean Security Groups
1. Go to **Security Groups** section
2. Select your custom security group (USERNAME-web-sg)
3. **Actions** → **Delete security group**
4. Confirm deletion

---

## Troubleshooting

### Common Issues and Solutions

**Issue: Cannot connect to web server**
- **Solution:** Check security group allows HTTP (port 80) from 0.0.0.0/0
- **Verify:** Apache service is running: `sudo systemctl status httpd`

**Issue: EC2 Instance Connect fails**
- **Solution:** Ensure security group allows SSH (port 22)
- **Alternative:** Use SSH with downloaded key pair

**Issue: AMI creation takes long time**
- **Solution:** This is normal, can take 10-15 minutes
- **Monitor:** Check AMI status in AWS console

**Issue: New instance from AMI doesn't work**
- **Solution:** Verify security group and networking configuration
- **Check:** Instance status checks are passing

---

## Validation Checklist

- [ ] Successfully launched EC2 instance with correct tags (USERNAME prefix)
- [ ] Security group configured with SSH (22) and HTTP (80) access
- [ ] Apache web server installed and running
- [ ] Custom web page displays in browser with your username
- [ ] Custom AMI created successfully with your username prefix
- [ ] New instance launched from AMI works correctly
- [ ] All resources cleaned up properly

---

## Key Concepts Learned

1. **EC2 Instance Lifecycle:** Launch, configure, manage, and terminate
2. **Security Groups:** Virtual firewalls controlling network access
3. **AMI (Amazon Machine Image):** Templates for launching instances
4. **User Data vs AMI:** Different approaches to instance configuration
5. **Instance Metadata:** Information available to running instances

---

## Next Steps

- **Lab 2:** AMI Creation & Instance Lifecycle
- **Lab 3:** IAM Configuration & Security
- **Advanced Topics:** Auto Scaling, Load Balancing, Advanced Networking

---

**Lab Duration:** 45 minutes  
**Difficulty:** Beginner  
**Prerequisites:** AWS Console access, assigned username

EOF



    # Create lab completion tracking
    cat > lab-progress.md << 'EOF'
# Lab 1 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: Launch EC2 Instance
- [ ] Navigated to EC2 Dashboard
- [ ] Selected Amazon Linux 2 AMI
- [ ] Configured t2.micro instance
- [ ] Set up proper networking (VPC, subnet, public IP)
- [ ] Added name tag: `USERNAME-web-server` (with your username)
- [ ] Created security group: `USERNAME-web-sg` (with your username)
- [ ] Created and downloaded key pair: `USERNAME-keypair` (with your username)
- [ ] Successfully launched instance

### Task 2: Configure Web Server
- [ ] Connected to instance via EC2 Instance Connect
- [ ] Updated system packages
- [ ] Installed Apache web server
- [ ] Started and enabled Apache service
- [ ] Created custom HTML page
- [ ] Replaced USERNAME placeholder with your actual username
- [ ] Set proper file permissions
- [ ] Tested web server locally
- [ ] Verified external web access

### Task 3: Create Custom AMI
- [ ] Created AMI from running instance: `USERNAME-web-server-ami`
- [ ] Monitored AMI creation status
- [ ] Waited for AMI to become available
- [ ] Launched new instance from custom AMI: `USERNAME-web-server-2`
- [ ] Verified AMI persistence (Apache auto-starts)
- [ ] Tested new instance web server

### Cleanup
- [ ] Terminated all instances (USERNAME-web-server, USERNAME-web-server-2)
- [ ] Deregistered custom AMI (USERNAME-web-server-ami)
- [ ] Deleted associated snapshots
- [ ] Removed custom security group (USERNAME-web-sg)
- [ ] Verified all resources deleted

## Notes

**Your Username:** ________________

**Resource Names (with your username):**
- Instance 1: ________________-web-server
- Instance 2: ________________-web-server-2
- AMI: ________________-web-server-ami
- Security Group: ________________-web-sg
- Key Pair: ________________-keypair

**Instance IDs:**
- Original instance: ________________
- AMI-based instance: _______________

**Public IPs:**
- Original instance: ________________
- AMI-based instance: _______________

**Issues Encountered:**


**Solutions Applied:**


**Time Completed:** ________________

EOF

    # Create summary of created files
    cat > FILES.md << 'EOF'
# Lab 1 Files

This directory contains all files needed for Lab 1: EC2 Basics & Instance Management.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **FILES.md** - This file, describing all lab files

## Usage

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Remember to replace USERNAME with your assigned username throughout the lab

## Important Notes

- Replace USERNAME placeholder with your assigned username (user1, user2, user3, etc.)
- All resource names must include your username prefix for uniqueness
- Follow cleanup instructions carefully to remove all resources

EOF

    print_status "Lab files created successfully!"
    print_status "Lab directory: $LAB_DIR"
    
    echo ""
    print_header "Lab 1 Setup Complete"
    echo -e "${GREEN}✅ Lab directory created: ${BLUE}$LAB_DIR${NC}"
    echo -e "${GREEN}✅ README.md with complete instructions${NC}"
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
    echo -e "${BLUE}Difficulty: Beginner${NC}"
    echo -e "${BLUE}Focus: EC2 Fundamentals${NC}"
}

# Run main function
main "$@"