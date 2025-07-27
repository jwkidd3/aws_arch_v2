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

