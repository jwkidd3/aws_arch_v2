#!/bin/bash

# Lab 3 Setup Script: IAM Configuration & Security
# AWS Architecting Course - Day 1, Session 3
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
    print_header "AWS Architecting Course - Lab 3 Setup"
    print_status "Setting up IAM Configuration & Security Lab"
    
    # Create lab directory structure
    LAB_DIR="lab3-iam-security"
    
    if [ -d "$LAB_DIR" ]; then
        print_warning "Directory $LAB_DIR already exists. Removing and recreating..."
        rm -rf "$LAB_DIR"
    fi
    
    mkdir -p "$LAB_DIR/policies"
    mkdir -p "$LAB_DIR/scripts"
    cd "$LAB_DIR"
    
    print_status "Creating lab files in directory: $LAB_DIR"
    
    # Create README.md with lab instructions
    cat > README.md << 'EOF'
# Lab 3: IAM Configuration & Security

**Duration:** 45 minutes  
**Objective:** Master IAM fundamentals including users, groups, roles, policies, and security best practices.

## Prerequisites
- Access to AWS Management Console
- Your assigned username (user1, user2, user3, etc.)
- Completion of Lab 1 (EC2 Basics)

## Important: Username Setup
🔧 **Before starting:** Replace `USERNAME` with your assigned username (e.g., user1, user2, user3) in all instructions below.

## Learning Outcomes
After completing this lab, you will be able to:
- Create and manage IAM users, groups, and roles
- Design and implement custom IAM policies
- Configure multi-factor authentication (MFA)
- Apply the principle of least privilege
- Troubleshoot common IAM permission issues

---

## Task 1: Create IAM Users and Groups (15 minutes)

### Step 1: Create IAM Groups
1. **Navigate to IAM:**
   - In the AWS Management Console, search for "IAM"
   - Click on **Identity and Access Management (IAM)**

2. **Create Developer Group:**
   - In the left navigation, click **User groups**
   - Click **Create group**
   - **Group name:** `USERNAME-developers` ⚠️ **Replace USERNAME with your assigned username**
   - **Attach permissions policies:**
     - Search for and select **AmazonEC2ReadOnlyAccess**
     - Search for and select **AmazonS3ReadOnlyAccess**
   - Click **Create group**

3. **Create Admin Group:**
   - Click **Create group**
   - **Group name:** `USERNAME-admins` ⚠️ **Replace USERNAME with your assigned username**
   - **Attach permissions policies:**
     - Search for and select **PowerUserAccess**
   - Click **Create group**

### Step 2: Create IAM Users
1. **Create Developer User:**
   - In the left navigation, click **Users**
   - Click **Create user**
   - **User name:** `USERNAME-dev-user` ⚠️ **Replace USERNAME with your assigned username**
   - **Select AWS access type:**
     - ✅ **Provide user access to the AWS Management Console**
     - Select **I want to create an IAM user**
   - **Console password:**
     - Select **Custom password**
     - Enter: `TempPassword123!`
     - ✅ **Users must create a new password at next sign-in**
   - Click **Next**

2. **Add User to Group:**
   - **Add user to group:** Select `USERNAME-developers`
   - Click **Next**

3. **Review and Create:**
   - Review the configuration
   - Click **Create user**

4. **Create Admin User:**
   - Click **Create user**
   - **User name:** `USERNAME-admin-user` ⚠️ **Replace USERNAME with your assigned username**
   - **Select AWS access type:**
     - ✅ **Provide user access to the AWS Management Console**
     - Select **I want to create an IAM user**
   - **Console password:**
     - Select **Custom password**
     - Enter: `AdminPassword123!`
     - ✅ **Users must create a new password at next sign-in**
   - Click **Next**

5. **Add to Admin Group:**
   - **Add user to group:** Select `USERNAME-admins`
   - Click **Next**
   - Click **Create user**

### Step 3: Test User Access
1. **Get Sign-in URL:**
   - In IAM Dashboard, note the **AWS Account ID**
   - Sign-in URL format: `https://ACCOUNT-ID.signin.aws.amazon.com/console`

2. **Test Developer User:**
   - Open an incognito/private browser window
   - Navigate to the sign-in URL
   - Sign in as `USERNAME-dev-user` with temporary password
   - Change password when prompted
   - Try to access EC2 (should work - read-only)
   - Try to launch an instance (should fail)
   - Sign out

---

## Task 2: Create Custom IAM Policies (15 minutes)

### Step 1: Create S3 Restricted Policy
1. **Navigate to Policies:**
   - In IAM, click **Policies** in left navigation
   - Click **Create policy**

2. **Define Policy Using Visual Editor:**
   - **Service:** S3
   - **Actions:**
     - **List:** Select `ListBucket`, `ListAllMyBuckets`
     - **Read:** Select `GetObject`
     - **Write:** Select `PutObject`, `DeleteObject`
   - **Resources:**
     - **bucket:** Click **Add ARN**
       - **Bucket name:** `USERNAME-*` ⚠️ **Replace USERNAME with your assigned username**
       - Click **Add**
     - **object:** Click **Add ARN**
       - **Bucket name:** `USERNAME-*` ⚠️ **Replace USERNAME with your assigned username**
       - **Object name:** `*`
       - Click **Add**

3. **Review and Create Policy:**
   - Click **Next: Tags** (skip tags)
   - Click **Next: Review**
   - **Name:** `USERNAME-S3-Limited-Access` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** `Allows access only to USERNAME-prefixed S3 buckets`
   - Click **Create policy**

### Step 2: Create EC2 Management Policy
1. **Create New Policy:**
   - Click **Create policy**
   - Click **JSON** tab

2. **Enter Custom JSON Policy:**
   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": [
                   "ec2:DescribeInstances",
                   "ec2:DescribeImages",
                   "ec2:DescribeKeyPairs",
                   "ec2:DescribeSecurityGroups",
                   "ec2:DescribeSubnets",
                   "ec2:DescribeVpcs"
               ],
               "Resource": "*"
           },
           {
               "Effect": "Allow",
               "Action": [
                   "ec2:RunInstances"
               ],
               "Resource": "*",
               "Condition": {
                   "StringEquals": {
                       "ec2:InstanceType": [
                           "t2.micro",
                           "t2.small"
                       ]
                   }
               }
           },
           {
               "Effect": "Allow",
               "Action": [
                   "ec2:StartInstances",
                   "ec2:StopInstances",
                   "ec2:RebootInstances"
               ],
               "Resource": "*",
               "Condition": {
                   "StringLike": {
                       "ec2:ResourceTag/Name": "USERNAME-*"
                   }
               }
           },
           {
               "Effect": "Deny",
               "Action": [
                   "ec2:TerminateInstances"
               ],
               "Resource": "*",
               "Condition": {
                   "StringEquals": {
                       "ec2:ResourceTag/Environment": "Production"
                   }
               }
           }
       ]
   }
   ```

3. **Important:** Replace `USERNAME-*` in the JSON with your actual username prefix (e.g., `user1-*`)

4. **Complete Policy Creation:**
   - Click **Next: Tags** (skip tags)
   - Click **Next: Review**
   - **Name:** `USERNAME-EC2-Controlled-Access` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** `Controlled EC2 access with instance type and tag restrictions`
   - Click **Create policy**

### Step 3: Test Custom Policies
1. **Attach Policy to Developer User:**
   - Navigate to **Users**
   - Click on `USERNAME-dev-user`
   - Click **Add permissions**
   - Select **Attach policies directly**
   - Search for and select your custom policies:
     - `USERNAME-S3-Limited-Access`
     - `USERNAME-EC2-Controlled-Access`
   - Click **Next: Review**
   - Click **Add permissions**

---

## Task 3: Create and Configure IAM Roles (15 minutes)

### Step 1: Create EC2 Service Role
1. **Create Role:**
   - In IAM, click **Roles** in left navigation
   - Click **Create role**

2. **Select Trusted Entity:**
   - **Trusted entity type:** AWS service
   - **Use case:** EC2
   - Click **Next**

3. **Add Permissions:**
   - Search for and select **AmazonS3ReadOnlyAccess**
   - Search for and select **CloudWatchAgentServerPolicy**
   - Click **Next**

4. **Name and Create Role:**
   - **Role name:** `USERNAME-EC2-S3-Role` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** `Allows EC2 instances to access S3 and CloudWatch`
   - Click **Create role**

### Step 2: Create Cross-Account Access Role (Demo)
1. **Create Cross-Account Role:**
   - Click **Create role**
   - **Trusted entity type:** AWS account
   - **An AWS account:** This account (your account ID)
   - Click **Next**

2. **Add Permissions:**
   - Search for and select **ReadOnlyAccess**
   - Click **Next**

3. **Configure Role:**
   - **Role name:** `USERNAME-ReadOnly-CrossAccount` ⚠️ **Replace USERNAME with your assigned username**
   - **Description:** `Read-only access for cross-account scenarios`
   - Click **Create role**

### Step 3: Test Role with EC2 Instance
1. **Launch Test Instance:**
   - Navigate to EC2 console
   - Click **Launch Instance**
   - **Name:** `USERNAME-role-test` ⚠️ **Replace USERNAME with your assigned username**
   - **AMI:** Amazon Linux 2
   - **Instance type:** t2.micro
   - **IAM instance profile:** Select `USERNAME-EC2-S3-Role`
   - **Security group:** Create new with SSH access
   - **Key pair:** Use existing or create new
   - Click **Launch instance**

2. **Test Role Functionality:**
   - Connect to instance via EC2 Instance Connect
   - Run: `aws sts get-caller-identity`
   - Run: `aws s3 ls` (should work - S3 read access)
   - Run: `aws ec2 describe-instances` (should fail - no EC2 permissions)

---

## Cleanup Instructions

**⚠️ Important:** Clean up resources to avoid charges and maintain security

### Step 1: Terminate Test Instance
1. Navigate to EC2 console
2. Select `USERNAME-role-test` instance
3. **Instance State** → **Terminate instance**
4. Confirm termination

### Step 2: Clean Up IAM Resources
1. **Delete Users:**
   - Go to IAM → Users
   - Select `USERNAME-dev-user` and `USERNAME-admin-user`
   - Click **Delete** (type username to confirm)

2. **Delete Groups:**
   - Go to IAM → User groups
   - Select `USERNAME-developers` and `USERNAME-admins`
   - Click **Delete** (confirm deletion)

3. **Delete Custom Policies:**
   - Go to IAM → Policies
   - Filter by "Customer managed"
   - Select your custom policies:
     - `USERNAME-S3-Limited-Access`
     - `USERNAME-EC2-Controlled-Access`
   - Click **Delete** (type policy name to confirm)

4. **Delete Roles:**
   - Go to IAM → Roles
   - Select `USERNAME-EC2-S3-Role` and `USERNAME-ReadOnly-CrossAccount`
   - Click **Delete** (type role name to confirm)

---

## Troubleshooting

### Common Issues and Solutions

**Issue: "Access Denied" when testing user permissions**
- **Solution:** Check policy attachments and ensure correct ARNs
- **Verify:** User is in correct group with proper policies attached

**Issue: Custom policy JSON syntax errors**
- **Solution:** Validate JSON syntax and ensure all brackets are closed
- **Check:** Resource ARNs are correctly formatted

**Issue: Role assumption fails**
- **Solution:** Verify trust relationship and ensure service can assume role
- **Confirm:** EC2 service is listed in trust policy

**Issue: Cannot delete IAM resources**
- **Solution:** Remove all attachments first (policies from users/groups/roles)
- **Order:** Delete users → groups → policies → roles

---

## Validation Checklist

- [ ] Created IAM groups with appropriate policies (`USERNAME-developers`, `USERNAME-admins`)
- [ ] Created IAM users and assigned to groups (`USERNAME-dev-user`, `USERNAME-admin-user`)
- [ ] Tested user access and verified permissions work correctly
- [ ] Created custom S3 policy with resource restrictions (`USERNAME-S3-Limited-Access`)
- [ ] Created custom EC2 policy with conditions (`USERNAME-EC2-Controlled-Access`)
- [ ] Created IAM role for EC2 service (`USERNAME-EC2-S3-Role`)
- [ ] Tested role functionality with EC2 instance
- [ ] Created cross-account role for demonstration (`USERNAME-ReadOnly-CrossAccount`)
- [ ] Successfully cleaned up all created resources

---

## Key Concepts Learned

1. **IAM Hierarchy:** Users → Groups → Policies structure
2. **Policy Types:** AWS managed vs Customer managed policies
3. **Policy Elements:** Effect, Action, Resource, Condition
4. **Roles vs Users:** When to use service roles vs user credentials
5. **Principle of Least Privilege:** Granting minimum required permissions
6. **Trust Relationships:** How services assume roles
7. **Policy Conditions:** Adding security constraints to permissions
8. **Resource-Based Security:** Using tags and naming conventions

---

## Security Best Practices Applied

- ✅ Created users with temporary passwords requiring change
- ✅ Used groups for permission management (not individual user policies)
- ✅ Applied resource-level restrictions in custom policies
- ✅ Used conditions to limit instance types and actions
- ✅ Implemented deny policies for critical resources
- ✅ Created service roles instead of using user credentials
- ✅ Used descriptive naming conventions for resources

---

## Next Steps

- **Lab 4:** VPC Networking Setup
- **Advanced Topics:** Policy simulation, Access Analyzer, Cross-account roles
- **Security Enhancement:** MFA setup, Password policies, Access keys rotation

---

**Lab Duration:** 45 minutes  
**Difficulty:** Beginner to Intermediate  
**Prerequisites:** AWS Console access, assigned username

EOF

    # Create policy templates directory and files
    cat > policies/s3-limited-policy-template.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "arn:aws:s3:::USERNAME-*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::USERNAME-*/*"
        }
    ]
}
EOF

    cat > policies/ec2-controlled-policy-template.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeImages",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:InstanceType": [
                        "t2.micro",
                        "t2.small"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:RebootInstances"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/Name": "USERNAME-*"
                }
            }
        },
        {
            "Effect": "Deny",
            "Action": [
                "ec2:TerminateInstances"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:ResourceTag/Environment": "Production"
                }
            }
        }
    ]
}
EOF

    cat > policies/trust-policy-ec2.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

    # Create progress tracking file
    cat > lab-progress.md << 'EOF'
# Lab 3 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: Create IAM Users and Groups
- [ ] Created developer group: `USERNAME-developers`
- [ ] Created admin group: `USERNAME-admins`
- [ ] Attached appropriate AWS managed policies to groups
- [ ] Created developer user: `USERNAME-dev-user`
- [ ] Created admin user: `USERNAME-admin-user`
- [ ] Set temporary passwords for both users
- [ ] Added users to appropriate groups
- [ ] Tested user access and permissions

### Task 2: Create Custom IAM Policies
- [ ] Created S3 limited access policy: `USERNAME-S3-Limited-Access`
- [ ] Used visual editor for S3 policy creation
- [ ] Created EC2 controlled access policy: `USERNAME-EC2-Controlled-Access`
- [ ] Used JSON editor for EC2 policy creation
- [ ] Applied instance type conditions in EC2 policy
- [ ] Applied resource tag conditions in EC2 policy
- [ ] Added deny statement for production instances
- [ ] Attached custom policies to developer user
- [ ] Tested custom policy functionality

### Task 3: Create and Configure IAM Roles
- [ ] Created EC2 service role: `USERNAME-EC2-S3-Role`
- [ ] Attached S3ReadOnly and CloudWatch policies to role
- [ ] Created cross-account role: `USERNAME-ReadOnly-CrossAccount`
- [ ] Launched test EC2 instance with IAM role
- [ ] Tested role functionality from EC2 instance
- [ ] Verified S3 access works from instance
- [ ] Verified EC2 access denied from instance

### Cleanup
- [ ] Terminated test EC2 instance
- [ ] Deleted IAM users (USERNAME-dev-user, USERNAME-admin-user)
- [ ] Deleted IAM groups (USERNAME-developers, USERNAME-admins)
- [ ] Deleted custom policies (USERNAME-S3-Limited-Access, USERNAME-EC2-Controlled-Access)
- [ ] Deleted IAM roles (USERNAME-EC2-S3-Role, USERNAME-ReadOnly-CrossAccount)
- [ ] Verified all resources deleted

## Notes

**Your Username:** ________________

**Resource Names Created:**
- Developer Group: ________________-developers
- Admin Group: ________________-admins
- Developer User: ________________-dev-user
- Admin User: ________________-admin-user
- S3 Policy: ________________-S3-Limited-Access
- EC2 Policy: ________________-EC2-Controlled-Access
- EC2 Role: ________________-EC2-S3-Role
- Cross-Account Role: ________________-ReadOnly-CrossAccount

**Test Results:**
- Developer user EC2 access (read-only): ________________
- Developer user EC2 launch attempt: ________________
- Custom policy S3 access test: ________________
- Custom policy EC2 restrictions test: ________________
- Role-based S3 access from EC2: ________________

**Issues Encountered:**


**Solutions Applied:**


**Time Completed:** ________________

EOF

    # Create quick reference guide
    cat > quick-reference.md << 'EOF'
# Lab 3 Quick Reference Guide

## IAM Best Practices Checklist

### User Management
- ✅ Use groups for permission management
- ✅ Set temporary passwords requiring change
- ✅ Apply principle of least privilege
- ✅ Use meaningful naming conventions

### Policy Design
- ✅ Start with AWS managed policies when possible
- ✅ Use resource-level restrictions
- ✅ Apply conditions for additional security
- ✅ Include explicit deny statements when needed

### Role Configuration
- ✅ Use roles for service-to-service access
- ✅ Configure proper trust relationships
- ✅ Limit role session duration when appropriate
- ✅ Use external ID for cross-account access

## Common IAM Policy Elements

### Basic Structure
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow|Deny",
            "Action": "service:action",
            "Resource": "arn:aws:service:region:account:resource",
            "Condition": {
                "ConditionOperator": {
                    "ConditionKey": "value"
                }
            }
        }
    ]
}
```

### Useful Condition Keys
- `aws:username` - IAM user name
- `aws:userid` - Unique user ID
- `aws:CurrentTime` - Current date/time
- `aws:RequestedRegion` - AWS region
- `ec2:InstanceType` - EC2 instance type
- `s3:prefix` - S3 object prefix

### Resource ARN Formats
- S3 Bucket: `arn:aws:s3:::bucket-name`
- S3 Object: `arn:aws:s3:::bucket-name/*`
- EC2 Instance: `arn:aws:ec2:region:account:instance/*`
- IAM Role: `arn:aws:iam::account:role/role-name`

## Troubleshooting Commands

### Check Current Identity
```bash
aws sts get-caller-identity
```

### List S3 Buckets
```bash
aws s3 ls
```

### Describe EC2 Instances
```bash
aws ec2 describe-instances --region us-east-1
```

### Simulate Policy
```bash
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::account:user/username \
    --action-names s3:GetObject \
    --resource-arns arn:aws:s3:::bucket-name/object-key
```

EOF

    # Create summary of created files
    cat > FILES.md << 'EOF'
# Lab 3 Files

This directory contains all files needed for Lab 3: IAM Configuration & Security.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **quick-reference.md** - IAM best practices and reference guide
- **FILES.md** - This file, describing all lab files

## Policy Templates Directory

- **policies/s3-limited-policy-template.json** - S3 restricted access policy template
- **policies/ec2-controlled-policy-template.json** - EC2 controlled access policy template
- **policies/trust-policy-ec2.json** - EC2 service trust policy template

## Usage

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Reference **quick-reference.md** for IAM best practices and troubleshooting
4. Use policy templates in **policies/** directory as reference

## Important Notes

- Replace USERNAME placeholder with your assigned username throughout the lab
- All resource names must include your username prefix for uniqueness
- Follow cleanup instructions carefully to remove all resources
- Policy templates are for reference - actual policies created through console

EOF

    print_status "Lab files created successfully!"
    print_status "Lab directory: $LAB_DIR"
    
    echo ""
    print_header "Lab 3 Setup Complete"
    echo -e "${GREEN}✅ Lab directory created: ${BLUE}$LAB_DIR${NC}"
    echo -e "${GREEN}✅ README.md with complete instructions${NC}"
    echo -e "${GREEN}✅ Progress tracking checklist${NC}"
    echo -e "${GREEN}✅ IAM policy templates${NC}"
    echo -e "${GREEN}✅ Quick reference guide${NC}"
    echo -e "${GREEN}✅ Documentation files${NC}"
    
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. cd $LAB_DIR"
    echo "2. cat README.md  # Read complete lab instructions"
    echo "3. Replace USERNAME with your assigned username throughout the lab"
    echo "4. Follow the step-by-step procedures"
    echo "5. Use lab-progress.md to track completion"
    echo "6. Reference quick-reference.md for troubleshooting"
    
    echo ""
    echo -e "${BLUE}Lab Duration: 45 minutes${NC}"
    echo -e "${BLUE}Difficulty: Beginner to Intermediate${NC}"
    echo -e "${BLUE}Focus: IAM Security & Access Management${NC}"
}

# Run main function
main "$@"