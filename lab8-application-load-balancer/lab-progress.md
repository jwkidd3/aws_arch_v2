# Lab 8 Progress Tracking

**Important:** Replace USERNAME with your assigned username (e.g., user1, user2, user3) throughout this lab.

## Checklist

### Task 1: Prepare Infrastructure and Web Servers
- [ ] Launched first web server: `USERNAME-web-server-1` in private subnet AZ-a
- [ ] Launched second web server: `USERNAME-web-server-2` in private subnet AZ-b
- [ ] Created security group: `USERNAME-web-sg` (with your username)
- [ ] Applied user data scripts for web application setup
- [ ] Verified both instances are running and healthy
- [ ] Confirmed web applications are accessible from private network
- [ ] Created different application endpoints (/app, /api, /health)

### Task 2: Create Application Load Balancer
- [ ] Created target group: `USERNAME-web-tg` (with your username)
- [ ] Configured health checks for target group (/health endpoint)
- [ ] Registered both instances as targets
- [ ] Verified targets are healthy in target group
- [ ] Created ALB: `USERNAME-web-alb` (with your username)
- [ ] Configured ALB in public subnets across multiple AZs
- [ ] Created ALB security group: `USERNAME-alb-sg` (with your username)
- [ ] Configured listener on port 80 with default routing
- [ ] Verified ALB is active and accessible

### Task 3: Configure Advanced Routing and Test Load Balancing
- [ ] Created additional target groups: `USERNAME-app-tg` and `USERNAME-api-tg`
- [ ] Configured path-based routing rules for /app and /api paths
- [ ] Set appropriate rule priorities for routing
- [ ] Tested basic load balancing across both servers
- [ ] Verified path-based routing works correctly
- [ ] Monitored ALB metrics in CloudWatch
- [ ] Tested automatic failover behavior

### Advanced Exercises (Optional)
- [ ] Implemented sticky sessions for load balancer
- [ ] Tuned health check parameters
- [ ] Simulated server failure and tested failover
- [ ] Configured SSL/TLS termination (if applicable)

### Cleanup
- [ ] Deleted Application Load Balancer
- [ ] Deleted all target groups
- [ ] Terminated all web server instances
- [ ] Deleted custom security groups
- [ ] Verified all resources are cleaned up

## Notes

**Your Username:** ________________

**Resource Names (with your username):**
- Web Server 1: ________________-web-server-1
- Web Server 2: ________________-web-server-2
- Target Group Main: ________________-web-tg
- Target Group App: ________________-app-tg
- Target Group API: ________________-api-tg
- Application Load Balancer: ________________-web-alb
- ALB Security Group: ________________-alb-sg
- Web Security Group: ________________-web-sg

**Network Configuration:**
- VPC Used: ________________
- Public Subnets: ________________
- Private Subnets: ________________
- ALB DNS Name: ________________

**Testing Results:**
- Load balancing verified: [ ] Yes [ ] No
- Path-based routing working: [ ] Yes [ ] No
- Health checks functioning: [ ] Yes [ ] No
- Failover tested: [ ] Yes [ ] No

**Performance Metrics Observed:**
- Average response time: ________________
- Request distribution ratio: ________________
- Health check frequency: ________________

**Issues Encountered:**


**Solutions Applied:**


**Key Insights:**


**Time Completed:** ________________

