# Lab 7 Files

This directory contains all files needed for Lab 7: RDS Database Deployment.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **FILES.md** - This file, describing all lab files

## Lab Overview

This lab focuses on:
- Amazon RDS PostgreSQL database deployment
- Multi-AZ configuration for high availability
- Database subnet groups and security configuration
- Database connectivity from EC2 instances
- Failover testing and monitoring

## Key Learning Points

1. **RDS Multi-AZ:** Automatic failover, synchronous replication, high availability
2. **Database Security:** VPC isolation, security groups, encrypted connections
3. **Connectivity:** Proper network configuration, client tools, connection strings
4. **Monitoring:** CloudWatch metrics, performance tracking, failover validation
5. **Best Practices:** Security, backup configuration, maintenance windows

## Scripts Created During Lab

Students will create these files during the lab:

```
~/rds-lab/
├── database.ini          # Database connection configuration
└── query_postgres.py     # Python script for database queries
```

## Usage Instructions

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Remember to replace USERNAME with your assigned username throughout
4. Follow cleanup instructions carefully to avoid charges
5. Document any issues and solutions for future reference

## Important Notes

- All resource names must include your username prefix for uniqueness
- RDS instances take 10-15 minutes to launch and become available
- Multi-AZ deployment provides automatic failover in 60-120 seconds
- Always clean up RDS resources to avoid ongoing charges
- Security groups must allow PostgreSQL traffic (port 5432)

## Skills Developed

- RDS database deployment and configuration
- Multi-AZ setup for high availability
- Database security group configuration
- PostgreSQL client tools usage
- Database connectivity troubleshooting
- Failover testing and validation
- Python database programming
- AWS database monitoring and management

