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

