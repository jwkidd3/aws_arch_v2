# Lab 4 Files

This directory contains all files needed for Lab 4: VPC Networking Setup.

## Main Files

- **README.md** - Complete lab instructions and procedures
- **lab-progress.md** - Progress tracking checklist
- **networking-reference.md** - Comprehensive networking reference
- **validate-lab.py** - Python script to validate lab completion
- **FILES.md** - This file, describing all lab files

## Lab Overview

**Objective:** Create a production-ready VPC with public and private subnets, internet connectivity, and proper network isolation.

**Architecture:** 4-subnet design across 2 AZs with Internet Gateway and NAT Gateway.

**Duration:** 45 minutes

## Key Learning Points

1. VPC and subnet planning with CIDR blocks
2. Public vs private subnet concepts
3. Internet Gateway configuration
4. NAT Gateway setup for outbound internet access
5. Route table management
6. Multi-AZ network design for high availability

## Usage Instructions

1. Start with **README.md** for complete lab instructions
2. Use **lab-progress.md** to track your progress
3. Reference **networking-reference.md** for technical details
4. Run **validate-lab.py** to check your work (optional)
5. Remember to replace USERNAME with your assigned username throughout

## Important Notes

- All resource names must include your username prefix for uniqueness
- CIDR blocks are pre-calculated to avoid conflicts
- Follow cleanup instructions carefully to remove all resources
- NAT Gateway incurs costs - ensure proper cleanup

