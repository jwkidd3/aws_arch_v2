# Lab 4: VPC Networking Setup

**Duration:** 45 minutes  
**Objective:** Create and configure a Virtual Private Cloud (VPC) with public and private subnets, internet gateway, NAT gateway, and proper routing.

## Prerequisites
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)
- Basic understanding of networking concepts

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Create a custom VPC with CIDR blocks
- Configure public and private subnets across multiple AZs
- Set up Internet Gateway for internet connectivity
- Configure NAT Gateway for outbound internet access from private subnets
- Create and configure route tables
- Understand the difference between public and private subnets

---

## Architecture Overview

You will build the following network architecture:

```
┌─────────────────────────────────────────────────────────────────┐
│                    VPC: 10.0.0.0/26 (64 IPs)                   │
├─────────────────────────┬───────────────────────────────────────┤
│   Availability Zone A   │         Availability Zone B           │
├─────────────────────────┼───────────────────────────────────────┤
│ Public Subnet A         │ Public Subnet B                       │
│ 10.0.0.0/28 (16 IPs)    │ 10.0.0.32/28 (16 IPs)                │
├─────────────────────────┼───────────────────────────────────────┤
│ Private Subnet A        │ Private Subnet B                      │
│ 10.0.0.16/28 (16 IPs)   │ 10.0.0.48/28 (16 IPs)                │
└─────────────────────────┴───────────────────────────────────────┘
```

---

## Task 1: Create VPC and Subnets (15 minutes)

### Step 1: Create the VPC
1. **Navigate to VPC Service:**
   - In AWS Management Console, search for "VPC" in the services search bar
   - Click on **VPC** to open the VPC Dashboard

2. **Create VPC:**
   - In the left navigation menu, click **Your VPCs**
   - Click **Create VPC** button

3. **Configure VPC:**
   - **Name tag:** `USERNAME-prod-vpc` ⚠️ **Replace USERNAME with your assigned username**
   - **IPv4 CIDR block:** `10.0.0.0/26`
   - **IPv6 CIDR block:** No IPv6 CIDR block
   - **Tenancy:** Default
   - Click **Create VPC**

### Step 2: Create Subnets
1. **Navigate to Subnets:**
   - In the left navigation menu, click **Subnets**
   - Click **Create subnet** button

2. **Configure First Subnet (Public Subnet A):**
   - **VPC ID:** Select `USERNAME-prod-vpc` ⚠️ **Use your username**
   - **Subnet settings > Subnet 1 of 1:**
     - **Subnet name:** `USERNAME-public-subnet-a` ⚠️ **Replace USERNAME**
     - **Availability Zone:** `us-east-1a`
     - **IPv4 CIDR block:** `10.0.0.0/28`
   - Click **Add new subnet**

3. **Configure Second Subnet (Private Subnet A):**
   - **Subnet 2 of 2:**
     - **Subnet name:** `USERNAME-private-subnet-a` ⚠️ **Replace USERNAME**
     - **Availability Zone:** `us-east-1a`
     - **IPv4 CIDR block:** `10.0.0.16/28`
   - Click **Add new subnet**

4. **Configure Third Subnet (Public Subnet B):**
   - **Subnet 3 of 3:**
     - **Subnet name:** `USERNAME-public-subnet-b` ⚠️ **Replace USERNAME**
     - **Availability Zone:** `us-east-1b`
     - **IPv4 CIDR block:** `10.0.0.32/28`
   - Click **Add new subnet**

5. **Configure Fourth Subnet (Private Subnet B):**
   - **Subnet 4 of 4:**
     - **Subnet name:** `USERNAME-private-subnet-b` ⚠️ **Replace USERNAME**
     - **Availability Zone:** `us-east-1b`
     - **IPv4 CIDR block:** `10.0.0.48/28`
   - Click **Create subnet**

### Step 3: Verify Subnet Creation
- Verify all 4 subnets are created successfully
- Note the subnet IDs for future reference

---

## Task 2: Configure Internet Gateway (5 minutes)

### Step 1: Create Internet Gateway
1. **Navigate to Internet Gateways:**
   - In the left navigation menu, click **Internet Gateways**
   - Click **Create internet gateway** button

2. **Configure Internet Gateway:**
   - **Name tag:** `USERNAME-prod-igw` ⚠️ **Replace USERNAME with your assigned username**
   - Click **Create internet gateway**

### Step 2: Attach Internet Gateway to VPC
1. **Attach to VPC:**
   - Select your newly created internet gateway
   - Click **Actions** → **Attach to VPC**

2. **Select VPC:**
   - **Available VPCs:** Select `USERNAME-prod-vpc` ⚠️ **Use your username**
   - Click **Attach internet gateway**

3. **Verify Attachment:**
   - Confirm the state shows "Attached" to your VPC

---

## Task 3: Configure Route Tables for Public Subnets (10 minutes)

### Step 1: Create Public Route Table
1. **Navigate to Route Tables:**
   - In the left navigation menu, click **Route Tables**
   - Click **Create route table** button

2. **Configure Public Route Table:**
   - **Name:** `USERNAME-public-rt` ⚠️ **Replace USERNAME with your assigned username**
   - **VPC:** Select `USERNAME-prod-vpc` ⚠️ **Use your username**
   - Click **Create route table**

### Step 2: Add Internet Route to Public Route Table
1. **Edit Routes:**
   - Select your public route table
   - Click **Routes** tab
   - Click **Edit routes** button

2. **Add Internet Route:**
   - Click **Add route**
   - **Destination:** `0.0.0.0/0`
   - **Target:** Internet Gateway → Select `USERNAME-prod-igw` ⚠️ **Use your username**
   - Click **Save changes**

### Step 3: Associate Public Subnets
1. **Edit Subnet Associations:**
   - Click **Subnet associations** tab
   - Click **Edit subnet associations** button

2. **Select Public Subnets:**
   - Check boxes for:
     - `USERNAME-public-subnet-a` ⚠️ **Use your username**
     - `USERNAME-public-subnet-b` ⚠️ **Use your username**
   - Click **Save associations**

---

## Task 4: Configure NAT Gateway and Private Route Table (15 minutes)

### Step 1: Create NAT Gateway
1. **Navigate to NAT Gateways:**
   - In the left navigation menu, click **NAT Gateways**
   - Click **Create NAT Gateway** button

2. **Configure NAT Gateway:**
   - **Name:** `USERNAME-prod-nat` ⚠️ **Replace USERNAME with your assigned username**
   - **Subnet:** Select `USERNAME-public-subnet-a` ⚠️ **Use your username** (NAT goes in public subnet)
   - **Connectivity type:** Public
   - **Elastic IP allocation ID:** Click **Allocate Elastic IP**
   - Click **Create NAT Gateway**

3. **Wait for NAT Gateway:**
   - Wait for NAT Gateway state to become "Available" (takes 2-3 minutes)

### Step 2: Create Private Route Table
1. **Create Route Table:**
   - Click **Create route table** button
   - **Name:** `USERNAME-private-rt` ⚠️ **Replace USERNAME with your assigned username**
   - **VPC:** Select `USERNAME-prod-vpc` ⚠️ **Use your username**
   - Click **Create route table**

### Step 3: Add NAT Gateway Route to Private Route Table
1. **Edit Routes:**
   - Select your private route table
   - Click **Routes** tab
   - Click **Edit routes** button

2. **Add NAT Route:**
   - Click **Add route**
   - **Destination:** `0.0.0.0/0`
   - **Target:** NAT Gateway → Select `USERNAME-prod-nat` ⚠️ **Use your username**
   - Click **Save changes**

### Step 4: Associate Private Subnets
1. **Edit Subnet Associations:**
   - Click **Subnet associations** tab
   - Click **Edit subnet associations** button

2. **Select Private Subnets:**
   - Check boxes for:
     - `USERNAME-private-subnet-a` ⚠️ **Use your username**
     - `USERNAME-private-subnet-b` ⚠️ **Use your username**
   - Click **Save associations**

---

## Task 5: Test Network Connectivity (Optional - if time permits)

### Step 1: Launch Test Instance in Public Subnet
1. **Navigate to EC2:**
   - Go to EC2 service
   - Click **Launch Instances**

2. **Configure Instance:**
   - **Name:** `USERNAME-public-test` ⚠️ **Replace USERNAME**
   - **AMI:** Amazon Linux 2023
   - **Instance type:** t2.micro
   - **Key pair:** Create new or use existing
   - **Network settings:**
     - **VPC:** `USERNAME-prod-vpc` ⚠️ **Use your username**
     - **Subnet:** `USERNAME-public-subnet-a` ⚠️ **Use your username**
     - **Auto-assign public IP:** Enable
   - **Security group:** Allow SSH (port 22) from 0.0.0.0/0
   - Click **Launch instance**

### Step 2: Test Internet Connectivity
1. **Connect to Instance:**
   - Use EC2 Instance Connect or SSH
   - Test internet connectivity: `ping 8.8.8.8`
   - Should work (Ctrl+C to stop)

---

## Cleanup Instructions

**⚠️ Important:** Clean up resources to avoid charges

### Step 1: Terminate EC2 Instances (if created)
1. Go to **EC2 > Instances**
2. Select test instances
3. **Instance State** → **Terminate instance**

### Step 2: Delete NAT Gateway
1. Go to **VPC > NAT Gateways**
2. Select your NAT Gateway (`USERNAME-prod-nat`)
3. **Actions** → **Delete NAT gateway**
4. Type "delete" to confirm

### Step 3: Release Elastic IP
1. Go to **VPC > Elastic IPs**
2. Select the Elastic IP used by NAT Gateway
3. **Actions** → **Release Elastic IP addresses**
4. Confirm release

### Step 4: Delete VPC (This will delete associated resources)
1. Go to **VPC > Your VPCs**
2. Select your VPC (`USERNAME-prod-vpc`)
3. **Actions** → **Delete VPC**
4. Type "delete" to confirm

**Note:** Deleting the VPC will automatically delete:
- Subnets
- Route tables (except main route table)
- Internet Gateway attachment
- Security groups (except default)

---

## Troubleshooting

### Common Issues and Solutions

**Issue: Cannot delete VPC**
- **Solution:** Ensure all resources are deleted first (EC2 instances, NAT Gateway, etc.)
- **Check:** Network interfaces, security group references

**Issue: NAT Gateway creation fails**
- **Solution:** Ensure you're creating it in a public subnet
- **Verify:** Public subnet has route to Internet Gateway

**Issue: Private subnet cannot access internet**
- **Solution:** Check NAT Gateway is in "Available" state
- **Verify:** Private route table has 0.0.0.0/0 route to NAT Gateway

**Issue: Subnet CIDR conflicts**
- **Solution:** Ensure subnet CIDRs don't overlap
- **Check:** CIDR calculator: 10.0.0.0/26 allows 4 subnets of /28 each

---

## Validation Checklist

- [ ] VPC created with correct CIDR (10.0.0.0/26) and username prefix
- [ ] 4 subnets created across 2 AZs with correct CIDR blocks
- [ ] Internet Gateway created and attached to VPC
- [ ] Public route table created with internet route (0.0.0.0/0 → IGW)
- [ ] Public subnets associated with public route table
- [ ] NAT Gateway created in public subnet with Elastic IP
- [ ] Private route table created with NAT route (0.0.0.0/0 → NAT)
- [ ] Private subnets associated with private route table
- [ ] All resources properly tagged with username prefix
- [ ] Cleanup completed successfully

---

## Key Networking Concepts Learned

1. **VPC (Virtual Private Cloud):** Isolated network environment in AWS
2. **CIDR Blocks:** Network addressing and subnet planning
3. **Public vs Private Subnets:** Internet accessibility differences
4. **Internet Gateway:** Enables internet access for VPC
5. **NAT Gateway:** Allows outbound internet access for private resources
6. **Route Tables:** Control traffic routing within VPC
7. **Availability Zones:** Physical isolation for high availability
8. **Security Groups:** Virtual firewalls for instances

---

## Network Flow Summary

**Internet to Public Subnet:**
Internet → Internet Gateway → Public Subnet

**Public Subnet to Internet:**
Public Subnet → Internet Gateway → Internet

**Private Subnet to Internet (outbound only):**
Private Subnet → NAT Gateway (in public subnet) → Internet Gateway → Internet

**Internet to Private Subnet:**
Not possible (private subnets have no inbound internet access)

---

## Next Steps

- **Lab 5:** S3 Static Website Hosting
- **Lab 6:** EBS Volumes & Snapshots  
- **Advanced Topics:** VPC Peering, Transit Gateway, VPC Endpoints

---

**Lab Duration:** 45 minutes  
**Difficulty:** Beginner  
**Prerequisites:** Basic networking knowledge

