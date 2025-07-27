# Lab 9 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: Prepare Infrastructure for Auto Scaling
- [ ] Verified VPC setup with public subnets in multiple AZs
- [ ] Created security group: `USERNAME-asg-sg` (with your username)
- [ ] Created Application Load Balancer: `USERNAME-asg-alb`
- [ ] Created target group: `USERNAME-asg-tg`
- [ ] Verified ALB is in active state

### Task 2: Create Launch Template
- [ ] Created launch template: `USERNAME-asg-template` (with your username)
- [ ] Configured Amazon Linux 2023 AMI with t2.micro instance type
- [ ] Added comprehensive user data script for web server setup
- [ ] Replaced USERNAME placeholder in user data with actual username
- [ ] Verified launch template creation successful

### Task 3: Create Auto Scaling Group
- [ ] Created Auto Scaling group: `USERNAME-asg` (with your username)
- [ ] Configured capacity: Desired=2, Min=1, Max=6
- [ ] Attached to load balancer target group
- [ ] Enabled CloudWatch group metrics collection
- [ ] Set up target tracking scaling policy (CPU 50%)
- [ ] Added appropriate tags with username
- [ ] Verified initial instances launched successfully

### Task 4: Test Auto Scaling Policies
- [ ] Accessed load balancer URL and verified web application
- [ ] Generated CPU load using stress test
- [ ] Monitored CloudWatch metrics for CPU utilization
- [ ] Observed scale-out activity when CPU exceeded threshold
- [ ] Verified new instances were added to load balancer
- [ ] Stopped load test and monitored scale-in behavior
- [ ] Confirmed instances scaled back to desired capacity

### Advanced Exercises (Optional)
- [ ] Created step scaling policies with multiple thresholds
- [ ] Set up custom CloudWatch alarms for additional metrics
- [ ] Configured scheduled scaling policies

### Cleanup
- [ ] Set ASG capacity to 0 and waited for instance termination
- [ ] Deleted Auto Scaling group (USERNAME-asg)
- [ ] Deleted launch template (USERNAME-asg-template)
- [ ] Deleted Application Load Balancer (USERNAME-asg-alb)
- [ ] Deleted target group (USERNAME-asg-tg)
- [ ] Deleted security group (USERNAME-asg-sg)
- [ ] Removed key pair if created new (USERNAME-asg-keypair)
- [ ] Verified all resources cleaned up

## Notes

**Your Username:** ________________

**Resource Names (with your username):**
- Auto Scaling Group: ________________-asg
- Launch Template: ________________-asg-template
- Load Balancer: ________________-asg-alb
- Target Group: ________________-asg-tg
- Security Group: ________________-asg-sg

**Load Balancer DNS:** ________________

**Scaling Events Observed:**
- Scale-out triggered at: ________________
- Number of instances scaled to: ________________
- Scale-in triggered at: ________________
- Final number of instances: ________________

**CloudWatch Metrics:**
- Maximum CPU utilization reached: ________________%
- Scaling policy evaluation period: ________________
- Cooldown period observed: ________________

**Issues Encountered:**


**Solutions Applied:**


**Key Insights:**


**Time Completed:** ________________

