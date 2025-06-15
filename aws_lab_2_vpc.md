# Lab 2: VPC Configuration
## Build Production-Ready VPC Infrastructure

**Duration:** 90 minutes  
**Prerequisites:** Access to AWS Management Console

### Learning Objectives
By the end of this lab, you will be able to:
- Create a custom VPC with proper CIDR planning
- Configure public and private subnets across multiple Availability Zones
- Set up Internet Gateway for public internet access
- Configure NAT Gateway for private subnet internet access
- Understand routing tables and their associations
- Test connectivity between public and private instances
- Verify internet access from both subnet types

### Architecture Overview
You will create a production-ready VPC with the following components:
- **Custom VPC** with CIDR 10.0.0.0/26 (64 IP addresses)
- **4 subnets** of equal size (16 IPs each) across 2 Availability Zones
- **Public subnets** with direct internet access via Internet Gateway
- **Private subnets** with internet access via NAT Gateway
- **Route tables** to control traffic flow
- **Security groups** for network-level security

### Part 1: Create VPC and Subnets

#### Step 1: Create Custom VPC
1. In the AWS Management Console, search for and select **VPC**
2. Ensure you're in the **N. Virginia (US-East-1)** region
3. In the left navigation menu, click **Your VPCs**
4. Click **Create VPC**
5. Configure VPC settings:
   - **Name tag:** `MyProdVPC`
   - **IPv4 CIDR block:** `10.0.0.0/26`
   - Leave other settings as default
6. Click **Create VPC**

#### Step 2: Create Subnets
1. In the left navigation menu, click **Subnets**
2. Click **Create subnet**
3. Configure subnet settings:
   - **VPC ID:** Choose `MyProdVPC`

**Create Public Subnet A:**
- **Subnet name:** `public-subnet-a`
- **Availability Zone:** `us-east-1a`
- **IPv4 CIDR block:** `10.0.0.0/28`
- Click **Add new subnet**

**Create Private Subnet A:**
- **Subnet name:** `private-subnet-a`
- **Availability Zone:** `us-east-1a`
- **IPv4 CIDR block:** `10.0.0.16/28`
- Click **Add new subnet**

**Create Public Subnet B:**
- **Subnet name:** `public-subnet-b`
- **Availability Zone:** `us-east-1b`
- **IPv4 CIDR block:** `10.0.0.32/28`
- Click **Add new subnet**

**Create Private Subnet B:**
- **Subnet name:** `private-subnet-b`
- **Availability Zone:** `us-east-1b`
- **IPv4 CIDR block:** `10.0.0.48/28`

4. Click **Create subnet** to create all four subnets

### Part 2: Create Internet Gateway

#### Step 1: Create and Attach Internet Gateway
1. In the left navigation menu, click **Internet Gateways**
2. Click **Create internet gateway**
3. **Name tag:** `prod-igw`
4. Click **Create internet gateway**
5. Select the newly created gateway and click **Actions** → **Attach to VPC**
6. **Available VPCs:** Select `MyProdVPC`
7. Click **Attach internet gateway**

### Part 3: Configure Route Tables

#### Step 1: Create Public Route Table
1. In the left navigation menu, click **Route Tables**
2. Click **Create route table**
3. Configure route table:
   - **Name:** `public-rt`
   - **VPC:** Choose `MyProdVPC`
4. Click **Create route table**

#### Step 2: Configure Public Route Table
1. Select the `public-rt` route table
2. Click the **Routes** tab, then **Edit routes**
3. Click **Add route**
4. Configure the route:
   - **Destination:** `0.0.0.0/0`
   - **Target:** Internet Gateway → select `prod-igw`
5. Click **Save changes**

#### Step 3: Associate Public Subnets
1. With `public-rt` selected, click the **Subnet associations** tab
2. Click **Edit subnet associations**
3. Check both public subnets:
   - `public-subnet-a`
   - `public-subnet-b`
4. Click **Save associations**

### Part 4: Create NAT Gateway

#### Step 1: Create NAT Gateway
1. In the left navigation menu, click **NAT Gateways**
2. Click **Create NAT Gateway**
3. Configure NAT Gateway:
   - **Name:** `myNAT`
   - **Subnet:** Select `public-subnet-a` (must be a public subnet)
   - Click **Allocate Elastic IP**
4. Click **Create NAT Gateway**
5. Wait for the NAT Gateway to become **Available** (takes a few minutes)

#### Step 2: Create Private Route Table
1. Navigate back to **Route Tables**
2. Click **Create route table**
3. Configure route table:
   - **Name:** `private-rt`
   - **VPC:** Choose `MyProdVPC`
4. Click **Create route table**

#### Step 3: Configure Private Route Table
1. Select the `private-rt` route table
2. Click the **Routes** tab, then **Edit routes**
3. Click **Add route**
4. Configure the route:
   - **Destination:** `0.0.0.0/0`
   - **Target:** NAT Gateway → select `myNAT`
5. Click **Save changes**

#### Step 4: Associate Private Subnets
1. With `private-rt` selected, click the **Subnet associations** tab
2. Click **Edit subnet associations**
3. Check both private subnets:
   - `private-subnet-a`
   - `private-subnet-b`
4. Click **Save associations**

### Part 5: Launch Test Instances

#### Step 1: Launch Public Instance
1. Navigate to **EC2** service
2. Click **Launch Instances**
3. Configure instance:
   - **AMI:** Amazon Linux 2 AMI (HVM)
   - **Instance Type:** t2.micro
   - **Network:** `MyProdVPC`
   - **Subnet:** Select `public-subnet-a`
   - **Auto-assign Public IP:** Enable
   - **Security Group:** Create new with HTTP (80) and SSH (22) from anywhere
   - **Tag:** Name = `Public Instance`
4. Create or select a key pair
5. Launch the instance

#### Step 2: Launch Private Instance
1. Click **Launch Instances** again
2. Configure instance:
   - **AMI:** Amazon Linux 2 AMI (HVM)
   - **Instance Type:** t2.micro
   - **Network:** `MyProdVPC`
   - **Subnet:** Select `private-subnet-a`
   - **Auto-assign Public IP:** Disable
   - **Security Group:** Create new with HTTP (80) and SSH (22) from anywhere
   - **Tag:** Name = `Private Instance`
3. Create or select a key pair
4. Launch the instance

### Part 6: Test Connectivity

#### Step 1: Prepare for Testing
1. Create an S3 bucket and upload your private instance key file (.pem)
2. Make the key file public:
   - Select the bucket → **Permissions** tab
   - Edit **Block public access** and turn it **Off**
   - Select the key file → **Actions** → **Make public via ACL**
   - Copy the **Object URL** for later use

#### Step 2: Test Public Instance Internet Access
1. Select your **Public Instance** and click **Connect**
2. Use **EC2 Instance Connect** to open a browser terminal
3. Test internet connectivity:
   ```bash
   wget https://google.com
   ```
4. You should see a successful download

#### Step 3: Connect to Private Instance
1. From the public instance terminal, download the private key:
   ```bash
   wget [YOUR-S3-OBJECT-URL]
   ```
2. Set proper permissions on the key file:
   ```bash
   chmod 400 [your-key-filename].pem
   ```
3. SSH to the private instance:
   ```bash
   ssh -i "[your-key-filename].pem" ec2-user@[PRIVATE-INSTANCE-PRIVATE-IP]
   ```

#### Step 4: Test Private Instance Internet Access
1. From the private instance, test internet connectivity:
   ```bash
   wget https://google.com
   ```
2. You should see a successful download (through NAT Gateway)

### Part 7: Test NAT Gateway Functionality

#### Step 1: Verify Current Connectivity
Ensure both instances can access the internet as verified above.

#### Step 2: Remove NAT Gateway
1. Navigate to **NAT Gateways**
2. Select `myNAT` and click **Actions** → **Delete NAT Gateway**
3. Type "delete" to confirm
4. Navigate to **Elastic IPs**
5. Select the unassociated Elastic IP and click **Actions** → **Release Elastic IP addresses**

#### Step 3: Test Connectivity After NAT Removal
1. From the public instance, test internet access:
   ```bash
   wget https://google.com
   ```
   **Result:** Should still work (via Internet Gateway)

2. From the private instance, test internet access:
   ```bash
   wget https://google.com
   ```
   **Result:** Should fail (no internet route available)

This demonstrates that:
- Public instances access internet directly through Internet Gateway
- Private instances require NAT Gateway for internet access
- Private instances remain isolated when NAT Gateway is removed

### Part 8: Cleanup Resources

⚠️ **Important:** Clean up all resources to avoid charges

#### Step 1: Stop and Terminate Instances
1. **Stop** the Public Instance
2. **Terminate** the Private Instance

#### Step 2: Delete VPC Components (in order)
1. Delete any remaining NAT Gateways
2. Release all Elastic IP addresses
3. Delete the VPC (this will cascade delete subnets, route tables, and internet gateway)

#### Step 3: Clean Up S3
1. Delete the S3 bucket and its contents

### Key Concepts Learned

**CIDR Planning:**
- /26 provides 64 IP addresses for the VPC
- /28 provides 16 IP addresses per subnet
- AWS reserves 5 IP addresses per subnet

**Routing:**
- Route tables control traffic flow
- 0.0.0.0/0 represents all internet traffic
- Most specific route takes precedence

**Network Security:**
- Public subnets have direct internet access
- Private subnets access internet through NAT Gateway
- Security groups act as instance-level firewalls

**High Availability:**
- Multi-AZ deployment provides redundancy
- NAT Gateway should be deployed in each AZ for production

### Troubleshooting Tips

**Cannot reach internet from public instance:**
- Check route table has 0.0.0.0/0 → Internet Gateway
- Verify security group allows outbound HTTPS (443)
- Ensure instance has public IP address

**Cannot SSH to private instance:**
- Verify you're connecting from public instance in same VPC
- Check security group allows SSH from public subnet CIDR
- Ensure private key permissions are 400

**Private instance cannot reach internet:**
- Verify NAT Gateway is in Available state
- Check private route table has 0.0.0.0/0 → NAT Gateway
- Ensure NAT Gateway is in a public subnet

### Next Steps
In the next lab, you'll work with databases and learn to deploy RDS instances in your private subnets for secure data storage.