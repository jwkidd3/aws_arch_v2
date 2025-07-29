# Lab 8 Troubleshooting Guide

## Common Issues and Solutions

### Target Health Issues

**Problem:** Targets show as "unhealthy"
- **Cause:** Web server not running or health check path not accessible
- **Solution:** Verify httpd service is running and /health endpoint exists
- **Check:** SSH to instance and run `sudo systemctl status httpd`

**Problem:** Health check fails
- **Cause:** Wrong health check path or security group rules
- **Solution:** Verify health check path matches endpoint (e.g., /health)
- **Check:** Security group allows HTTP traffic from ALB

### Load Balancer Issues

**Problem:** ALB returns 503 Service Unavailable
- **Cause:** No healthy targets available
- **Solution:** Check target health and fix underlying issues
- **Check:** Target group health status and instance status

**Problem:** Path-based routing not working
- **Cause:** Incorrect listener rules or rule priorities
- **Solution:** Verify rules are configured with correct paths and priorities
- **Check:** Listener rules configuration in ALB console

### Connectivity Issues

**Problem:** Cannot access ALB from internet
- **Cause:** Security group not allowing inbound traffic
- **Solution:** Ensure ALB security group allows HTTP/HTTPS from 0.0.0.0/0
- **Check:** ALB security group rules

**Problem:** Instances not accessible from ALB
- **Cause:** Instance security group blocking ALB traffic
- **Solution:** Allow HTTP traffic from ALB security group
- **Check:** Instance security group inbound rules

### Performance Issues

**Problem:** High response times
- **Cause:** Instance overload or network latency
- **Solution:** Check instance CPU utilization and network performance
- **Monitor:** CloudWatch metrics for both ALB and instances

**Problem:** Uneven load distribution
- **Cause:** Sticky sessions or long-running connections
- **Solution:** Verify load balancing algorithm and connection settings
- **Check:** Target group settings and connection draining

## Debugging Commands

### Check Instance Status
```bash
# On instance
sudo systemctl status httpd
curl localhost/health
netstat -tlnp | grep :80
```

### Test Connectivity
```bash
# From another instance in same VPC
curl http://INSTANCE_PRIVATE_IP/
curl http://INSTANCE_PRIVATE_IP/health
```

### Monitor Logs
```bash
# Apache access logs
sudo tail -f /var/log/httpd/access_log

# Apache error logs
sudo tail -f /var/log/httpd/error_log
```

