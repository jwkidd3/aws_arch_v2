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

