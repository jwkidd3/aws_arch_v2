# Lab 7: RDS Database Deployment - Progress Tracker

## Checklist

### Task 1: VPC and Security Setup
- [ ] Verified VPC configuration from Lab 4
- [ ] Confirmed private subnets in multiple AZs exist
- [ ] Created DB subnet group: `USERNAME-rds-subnet-group` (with your username)
- [ ] Created RDS security group: `USERNAME-rds-sg`
- [ ] Configured PostgreSQL (5432) access rule
- [ ] Verified security group source points to EC2 security group

### Task 2: Launch EC2 Instance for Database Access
- [ ] Launched EC2 instance: `USERNAME-db-client` (with your username)
- [ ] Connected to instance successfully
- [ ] Installed PostgreSQL client (psql)
- [ ] Installed Python3 and pip
- [ ] Created ~/rds-lab directory
- [ ] Verified tools: `psql --version` and `python3 --version`

### Task 3: Create RDS PostgreSQL Database
- [ ] Selected PostgreSQL engine with Multi-AZ deployment
- [ ] Configured database identifier: `USERNAME-postgres-db`
- [ ] Set master username: `dbadmin`
- [ ] Set master password: `SecurePass123!`
- [ ] Selected db.t3.micro instance class
- [ ] Configured 20 GiB gp2 storage
- [ ] Selected correct VPC and subnet group
- [ ] Applied security group: `USERNAME-rds-sg`
- [ ] Set initial database name: `myappdb`
- [ ] Disabled deletion protection for lab cleanup
- [ ] Database reached "Available" status

### Task 4: Test Database Connectivity
- [ ] Created database.ini configuration file
- [ ] Updated configuration with actual RDS endpoint
- [ ] Successfully connected using psql command
- [ ] Created employees table with sample data
- [ ] Inserted 4 employee records
- [ ] Verified data with SELECT query
- [ ] Installed Python dependencies: psycopg2-binary
- [ ] Created and tested query_postgres.py script
- [ ] Script successfully displays employee data

### Task 5: Test Multi-AZ Failover
- [ ] Recorded initial private IP of RDS endpoint
- [ ] Initiated "Reboot with failover" from RDS console
- [ ] Waited for database to return to "Available" status
- [ ] Verified IP address changed after failover
- [ ] Confirmed database connectivity still works post-failover
- [ ] Tested Python script works after failover
- [ ] Checked network interfaces in EC2 console

### Validation and Cleanup
- [ ] Verified all database operations work correctly
- [ ] Reviewed RDS monitoring metrics
- [ ] Confirmed Multi-AZ status in database configuration
- [ ] Deleted RDS database instance
- [ ] Deleted subnet group
- [ ] Terminated EC2 client instance
- [ ] Cleaned up security groups

## Notes

**Your Username:** ________________

**Resource Names (with your username):**
- VPC: ________________-vpc
- DB Subnet Group: ________________-rds-subnet-group
- RDS Security Group: ________________-rds-sg
- RDS Database: ________________-postgres-db
- EC2 Instance: ________________-db-client

**Database Connection Details:**
- Endpoint: ________________
- Master Username: dbadmin
- Database Name: myappdb
- Port: 5432

**Failover Test Results:**
- IP Before Failover: ________________
- IP After Failover: ________________
- Failover Duration: ________________
- Application Downtime: ________________

**Issues Encountered:**


**Solutions Applied:**


**Key Insights About RDS Multi-AZ:**


**Performance Observations:**


**Time Completed:** ________________

