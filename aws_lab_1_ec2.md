# Lab 1: EC2 Instance Management
## Launch, Configure, and Create Custom AMIs

**Duration:** 40 minutes  
**Prerequisites:** Access to AWS Management Console

### Learning Objectives
By the end of this lab, you will be able to:
- Launch and configure EC2 instances
- Connect to EC2 instances using EC2 Connect
- Install and configure web server software
- Create custom AMIs from configured instances
- Understand instance lifecycle and management
- Clean up resources properly

### Part 1: Launch Your First EC2 Instance

#### Step 1: Navigate to EC2 Service
1. In the AWS Management Console, search for and click **EC2**
2. Ensure you're in the **N. Virginia (US-East-1)** region
3. In the left-hand EC2 Dashboard navigation menu, click **Instances**

#### Step 2: Launch Instance
1. Click the **Launch Instances** button
2. **Step 1 - Choose AMI:** Click **Select** against **Amazon Linux 2 AMI (HVM)**
3. **Step 2 - Choose Instance Type:** Select **t2.micro** and click **Next**

#### Step 3: Configure Instance Details
1. **Step 3 - Configure Instance:**
   - **Network:** Select **Default**
   - **Subnet:** Select any subnet from the dropdown
   - **Auto-assign Public IP:** Select **Enable**
   - Click **Next**

#### Step 4: Configure Storage and Tags
1. **Step 4 - Add Storage:** Click **Next** (use defaults)
2. **Step 5 - Add Tags:** 
   - Add tag with **Key** = `Name` and **Value** = `Test Instance`
   - Click **Next**

#### Step 5: Configure Security Group
1. **Step 6 - Configure Security Group:**
   - Create a **new security group**
   - Ensure rules exist for:
     - **Port 22** (SSH) from anywhere (0.0.0.0/0)
     - **Port 80** (HTTP) from anywhere (0.0.0.0/0)
   - Click **Review & Launch**

#### Step 6: Launch and Create Key Pair
1. **Step 7 - Review:** Click **Launch**
2. **Key Pair Dialog:**
   - Select **Create a new key pair**
   - Give it a descriptive name
   - **Download** the key pair file (.pem)
   - Click **Launch Instances**

### Part 2: Connect and Configure Web Server

#### Step 1: Connect to Instance
1. Select your launched instance from the instances list
2. Click the **Connect** button
3. Choose **EC2 Instance Connect** tab
4. Click **Connect** (this opens a browser-based terminal)

#### Step 2: Install Apache Web Server
Execute the following commands in the terminal:

```bash
# Install Apache web server
sudo yum install -y httpd

# Enable Apache to start on boot
sudo systemctl enable httpd

# Start Apache service
sudo service httpd start
```

#### Step 3: Test Web Server
1. Copy your instance's **Public IP address** or **Public DNS hostname**
2. Open a new browser tab
3. Navigate to `http://[YOUR-PUBLIC-IP]` (use HTTP, not HTTPS)
4. You should see the Apache test page
5. **Optional:** Test from your mobile device using the same URL

### Part 3: Create Custom AMI

#### Step 1: Stop Instance
1. Select your instance in the EC2 console
2. Click **Instance State** → **Stop Instance**
3. Wait for the instance to reach "Stopped" state

#### Step 2: Create AMI
1. With your stopped instance selected, click **Actions**
2. Navigate to **Image and templates** → **Create Image**
3. **Image name:** Enter a descriptive name (e.g., "WebServer-AMI-v1")
4. **Image description:** Enter a description
5. Click **Create Image**

#### Step 3: Monitor AMI Creation
1. In the left navigation menu, click **AMIs**
2. Monitor the status until it shows **Available**
3. Note: This process may take several minutes

### Part 4: Launch Instance from Custom AMI

#### Step 1: Launch from Custom AMI
1. Select your newly created AMI
2. Click **Launch Instance from AMI**
3. Follow the same configuration steps as before:
   - **Instance Type:** t2.micro
   - **Network:** Default settings with public IP enabled
   - **Security Group:** Create new or reuse existing with HTTP/SSH access
   - **Key Pair:** Create new or reuse existing

#### Step 2: Verify Custom Configuration
1. Once the new instance is running, note its **Public IP address**
2. Open a browser and navigate to `http://[NEW-INSTANCE-PUBLIC-IP]`
3. **Verification:** You should see the Apache test page immediately without needing to install anything
4. This confirms your custom AMI preserved the web server installation

### Part 5: Cleanup Resources

⚠️ **Important:** Always clean up resources to avoid unnecessary charges

#### Step 1: Terminate Instances
1. Select all running instances
2. Click **Instance State** → **Terminate Instance**
3. Confirm termination
4. Wait for instances to reach "Terminated" state

#### Step 2: Clean Up AMIs and Snapshots
1. Navigate to **AMIs** in the left menu
2. Select your custom AMI(s)
3. Click **Actions** → **Deregister AMI**
4. Navigate to **Snapshots** in the left menu
5. Select associated snapshots
6. Click **Actions** → **Delete Snapshot**

#### Step 3: Clean Up Volumes
1. Navigate to **Volumes** in the left menu
2. Delete any unattached volumes (if any exist)

### Key Concepts Learned

**EC2 Instance Lifecycle:**
- Pending → Running → Stopping → Stopped → Terminated

**AMI Benefits:**
- Faster deployment of pre-configured instances
- Consistent environment across multiple instances
- Custom software and configuration preservation

**Security Groups:**
- Act as virtual firewalls
- Control inbound and outbound traffic
- Stateful (return traffic automatically allowed)

**Instance Metadata:**
- Available at `http://169.254.169.254/latest/meta-data/`
- Contains instance-specific information
- Useful for automation and scripting

### Troubleshooting Tips

**Cannot Connect:**
- Verify security group allows SSH (port 22) from your IP
- Ensure instance has public IP address
- Check that instance is in "running" state

**Web Server Not Accessible:**
- Verify security group allows HTTP (port 80) from anywhere
- Ensure you're using HTTP not HTTPS
- Confirm Apache service is running: `sudo systemctl status httpd`

**AMI Creation Issues:**
- Ensure instance is stopped before creating AMI
- Wait for AMI status to show "Available" before launching
- Check for any error messages in the console

### Next Steps
In the next lab, you'll create a custom VPC with public and private subnets, and launch instances in a more controlled network environment.