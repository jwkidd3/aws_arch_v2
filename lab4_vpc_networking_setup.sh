#!/bin/bash

# Lab 4 Setup Script: VPC Networking Setup
# AWS Architecting Course - Day 1, Session 4
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

# Main function
main() {
    print_header "AWS Architecting Course - Lab 4 Setup"
    print_status "Setting up VPC Networking Setup Lab"
    
    # Create lab directory structure
    LAB_DIR="lab4-vpc-networking"
    
    if [ -d "$LAB_DIR" ]; then
        print_warning "Directory $LAB_DIR already exists. Removing and recreating..."
        rm -rf "$LAB_DIR"
    fi
    
    mkdir -p "$LAB_DIR"
    cd "$LAB_DIR"
    
    print_status "Creating lab files in directory: $LAB_DIR"
    
    # Create README.md with lab instructions
    cat > README.md << 'EOF'
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

EOF

    # Create progress tracking file
    cat > lab-progress.md << 'EOF'
# Lab 4 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: Create VPC and Subnets
- [ ] Navigated to VPC Dashboard
- [ ] Created VPC with name: `USERNAME-prod-vpc` (with your username)
- [ ] Set VPC CIDR to 10.0.0.0/26
- [ ] Created public subnet A: `USERNAME-public-subnet-a` (10.0.0.0/28, us-east-1a)
- [ ] Created private subnet A: `USERNAME-private-subnet-a` (10.0.0.16/28, us-east-1a)
- [ ] Created public subnet B: `USERNAME-public-subnet-b` (10.0.0.32/28, us-east-1b)
- [ ] Created private subnet B: `USERNAME-private-subnet-b` (10.0.0.48/28, us-east-1b)
- [ ] Verified all subnets created successfully

### Task 2: Configure Internet Gateway
- [ ] Created Internet Gateway: `USERNAME-prod-igw` (with your username)
- [ ] Attached Internet Gateway to VPC
- [ ] Verified attachment state shows "Attached"

### Task 3: Configure Route Tables for Public Subnets
- [ ] Created public route table: `USERNAME-public-rt` (with your username)
- [ ] Added internet route (0.0.0.0/0 → Internet Gateway)
- [ ] Associated public subnets with public route table
- [ ] Verified route table associations

### Task 4: Configure NAT Gateway and Private Route Table
- [ ] Created NAT Gateway: `USERNAME-prod-nat` (with your username)
- [ ] Placed NAT Gateway in public subnet
- [ ] Allocated Elastic IP for NAT Gateway
- [ ] Waited for NAT Gateway to become "Available"
- [ ] Created private route table: `USERNAME-private-rt` (with your username)
- [ ] Added NAT route (0.0.0.0/0 → NAT Gateway)
- [ ] Associated private subnets with private route table

### Task 5: Test Network Connectivity (Optional)
- [ ] Launched test EC2 instance in public subnet
- [ ] Configured security group for SSH access
- [ ] Tested internet connectivity from public instance
- [ ] Verified network functionality

### Cleanup
- [ ] Terminated any test EC2 instances
- [ ] Deleted NAT Gateway
- [ ] Released Elastic IP address
- [ ] Deleted VPC (automatically deletes subnets, route tables, IGW attachment)
- [ ] Verified all resources cleaned up

## Notes

**Your Username:** ________________

**Resource Names (with your username):**
- VPC: ________________-prod-vpc
- Internet Gateway: ________________-prod-igw
- NAT Gateway: ________________-prod-nat
- Public Route Table: ________________-public-rt
- Private Route Table: ________________-private-rt
- Public Subnet A: ________________-public-subnet-a
- Private Subnet A: ________________-private-subnet-a
- Public Subnet B: ________________-public-subnet-b
- Private Subnet B: ________________-private-subnet-b

**Network Details:**
- VPC CIDR: 10.0.0.0/26
- Public Subnet A CIDR: 10.0.0.0/28
- Private Subnet A CIDR: 10.0.0.16/28
- Public Subnet B CIDR: 10.0.0.32/28
- Private Subnet B CIDR: 10.0.0.48/28

**Resource IDs:**
- VPC ID: ________________
- Internet Gateway ID: ________________
- NAT Gateway ID: ________________
- Elastic IP: ________________

**Issues Encountered:**


**Solutions Applied:**


**Time Completed:** ________________

EOF

    # Create networking reference file
    cat > networking-reference.md << 'EOF'
# VPC Networking Reference

## CIDR Block Planning

### Main VPC: 10.0.0.0/26 (64 total IPs)
- Network: 10.0.0.0
- Broadcast: 10.0.0.63
- Usable IPs: 10.0.0.1 - 10.0.0.62
- Total usable: 62 IPs (AWS reserves 5 IPs per subnet)

### Subnet Breakdown:
1. **Public Subnet A (us-east-1a):** 10.0.0.0/28
   - Range: 10.0.0.0 - 10.0.0.15 (16 IPs)
   - Usable: 10.0.0.4 - 10.0.0.14 (11 IPs)
   - Reserved by AWS: .0, .1, .2, .3, .15

2. **Private Subnet A (us-east-1a):** 10.0.0.16/28
   - Range: 10.0.0.16 - 10.0.0.31 (16 IPs)
   - Usable: 10.0.0.20 - 10.0.0.30 (11 IPs)
   - Reserved by AWS: .16, .17, .18, .19, .31

3. **Public Subnet B (us-east-1b):** 10.0.0.32/28
   - Range: 10.0.0.32 - 10.0.0.47 (16 IPs)
   - Usable: 10.0.0.36 - 10.0.0.46 (11 IPs)
   - Reserved by AWS: .32, .33, .34, .35, .47

4. **Private Subnet B (us-east-1b):** 10.0.0.48/28
   - Range: 10.0.0.48 - 10.0.0.63 (16 IPs)
   - Usable: 10.0.0.52 - 10.0.0.62 (11 IPs)
   - Reserved by AWS: .48, .49, .50, .51, .63

## AWS Reserved IP Addresses

In each subnet, AWS reserves 5 IP addresses:
- **First IP (.0):** Network address
- **Second IP (.1):** VPC router
- **Third IP (.2):** DNS server
- **Fourth IP (.3):** Reserved for future use
- **Last IP:** Network broadcast address

## Route Table Configuration

### Public Route Table
| Destination | Target | Purpose |
|-------------|--------|---------|
| 10.0.0.0/26 | Local | VPC internal traffic |
| 0.0.0.0/0 | Internet Gateway | Internet access |

### Private Route Table
| Destination | Target | Purpose |
|-------------|--------|---------|
| 10.0.0.0/26 | Local | VPC internal traffic |
| 0.0.0.0/0 | NAT Gateway | Outbound internet access |

## Network Flow Paths

### Public Subnet Internet Access (Bidirectional)
```
Internet ↔ Internet Gateway ↔ Public Subnet
```

### Private Subnet Internet Access (Outbound Only)
```
Private Subnet → NAT Gateway (in Public Subnet) → Internet Gateway → Internet
```

### VPC Internal Communication
```
Any Subnet ↔ Local Routes ↔ Any Subnet (within VPC)
```

## Security Considerations

1. **Public Subnets:** 
   - Resources get public IPs
   - Directly accessible from internet
   - Use security groups to control access

2. **Private Subnets:**
   - No public IPs assigned
   - Not directly accessible from internet
   - Can access internet via NAT Gateway

3. **NAT Gateway:**
   - Provides outbound internet access for private subnets
   - Stateful (allows return traffic)
   - Managed by AWS (highly available)

## Cost Considerations

- **VPC, Subnets, Route Tables, Internet Gateway:** Free
- **NAT Gateway:** Charged per hour + data processing
- **Elastic IP:** Free when associated, charged when unassociated
- **Data Transfer:** Charges apply for data out to internet

## Best Practices

1. **Subnet Design:** Plan CIDR blocks carefully to avoid conflicts
2. **Multi-AZ:** Distribute subnets across multiple AZs for HA
3. **Security:** Use private subnets for databases and internal services
4. **Naming:** Use consistent naming conventions with prefixes
5. **Documentation:** Maintain network diagrams and IP allocation records

EOF

    # Create validation script
    cat > validate-lab.py << 'EOF'
#!/usr/bin/env python3
"""
Lab 4 Validation Script
Validates VPC networking setup
"""

import boto3
import sys

def validate_vpc_lab(username):
    """Validate VPC lab completion"""
    
    print(f"🔍 Validating Lab 4 for user: {username}")
    print("=" * 50)
    
    try:
        ec2 = boto3.client('ec2')
        
        # Check VPC
        vpcs = ec2.describe_vpcs(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f'{username}-prod-vpc']},
                {'Name': 'cidr-block-association.cidr-block', 'Values': ['10.0.0.0/26']}
            ]
        )
        
        if not vpcs['Vpcs']:
            print("❌ VPC not found or incorrect CIDR")
            return False
        
        vpc_id = vpcs['Vpcs'][0]['VpcId']
        print(f"✅ VPC found: {vpc_id}")
        
        # Check subnets
        expected_subnets = [
            (f'{username}-public-subnet-a', '10.0.0.0/28', 'us-east-1a'),
            (f'{username}-private-subnet-a', '10.0.0.16/28', 'us-east-1a'),
            (f'{username}-public-subnet-b', '10.0.0.32/28', 'us-east-1b'),
            (f'{username}-private-subnet-b', '10.0.0.48/28', 'us-east-1b'),
        ]
        
        for subnet_name, cidr, az in expected_subnets:
            subnets = ec2.describe_subnets(
                Filters=[
                    {'Name': 'tag:Name', 'Values': [subnet_name]},
                    {'Name': 'cidr-block', 'Values': [cidr]},
                    {'Name': 'availability-zone', 'Values': [az]}
                ]
            )
            
            if subnets['Subnets']:
                print(f"✅ Subnet found: {subnet_name}")
            else:
                print(f"❌ Subnet missing: {subnet_name}")
                return False
        
        # Check Internet Gateway
        igws = ec2.describe_internet_gateways(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f'{username}-prod-igw']},
                {'Name': 'attachment.vpc-id', 'Values': [vpc_id]}
            ]
        )
        
        if igws['InternetGateways']:
            print(f"✅ Internet Gateway found and attached")
        else:
            print("❌ Internet Gateway not found or not attached")
            return False
        
        print("\n🎉 Lab 4 validation completed successfully!")
        return True
        
    except Exception as e:
        print(f"❌ Validation error: {str(e)}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 validate-lab.py <username>")
        sys.exit(1)
    
    username = sys.argv[1]
    success = validate_vpc_lab(username)
    sys.exit(0 if success else 1)
EOF

    # Create summary of files
    cat > FILES.md << 'EOF'
# Lab 4 Files

This directory contains all files needed for Lab 4: VPC Networking Setup.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **networking-reference.md** - Comprehensive networking reference
- **validate-lab.py** - Python script to validate lab completion
- **FILES.md** - This file, describing all lab files

## Lab Overview

**Objective:** Create a production-ready VPC with public and private subnets, internet connectivity, and proper network isolation.

**Architecture:** 4-subnet design across 2 AZs with Internet Gateway and NAT Gateway.

**Duration:** 45 minutes

## Key Learning Points

1. VPC and subnet planning with CIDR blocks
2. Public vs private subnet concepts
3. Internet Gateway configuration
4. NAT Gateway setup for outbound internet access
5. Route table management
6. Multi-AZ network design for high availability

## Usage Instructions

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Reference **networking-reference.md** for technical details
4. Run **validate-lab.py** to check your work (optional)
5. Remember to replace USERNAME with your assigned username throughout

## Important Notes

- All resource names must include your username prefix for uniqueness
- CIDR blocks are pre-calculated to avoid conflicts
- Follow cleanup instructions carefully to remove all resources
- NAT Gateway incurs costs - ensure proper cleanup

EOF

    print_status "Lab files created successfully!"
    print_status "Lab directory: $LAB_DIR"
    
    echo ""
    print_header "Lab 4 Setup Complete"
    echo -e "${GREEN}✅ Lab directory created: ${BLUE}$LAB_DIR${NC}"
    echo -e "${GREEN}✅ README.md with complete instructions${NC}"
    echo -e "${GREEN}✅ Progress tracking checklist${NC}"
    echo -e "${GREEN}✅ Networking reference guide${NC}"
    echo -e "${GREEN}✅ Validation script${NC}"
    echo -e "${GREEN}✅ Documentation files${NC}"
    
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. cd $LAB_DIR"
    echo "2. cat README.md  # Read complete lab instructions"
    echo "3. Replace USERNAME with your assigned username throughout the lab"
    echo "4. Follow the step-by-step procedures"
    echo "5. Use lab-progress.md to track completion"
    echo "6. Reference networking-reference.md for technical details"
    
    echo ""
    echo -e "${BLUE}Lab Duration: 45 minutes${NC}"
    echo -e "${BLUE}Difficulty: Beginner${NC}"
    echo -e "${BLUE}Focus: VPC Networking Fundamentals${NC}"
}

# Run main function
main "$@"