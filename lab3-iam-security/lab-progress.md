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

