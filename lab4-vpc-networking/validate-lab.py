#!/usr/bin/env python3
"""
Lab 4 Validation Script
Validates VPC networking setup
"""

import boto3
import sys

def validate_vpc_lab(username):
    """Validate VPC lab completion"""
    
    print(f"🔍 Validating Lab 4 for user: {username}")
    print("=" * 50)
    
    try:
        ec2 = boto3.client('ec2')
        
        # Check VPC
        vpcs = ec2.describe_vpcs(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f'{username}-prod-vpc']},
                {'Name': 'cidr-block-association.cidr-block', 'Values': ['10.0.0.0/26']}
            ]
        )
        
        if not vpcs['Vpcs']:
            print("❌ VPC not found or incorrect CIDR")
            return False
        
        vpc_id = vpcs['Vpcs'][0]['VpcId']
        print(f"✅ VPC found: {vpc_id}")
        
        # Check subnets
        expected_subnets = [
            (f'{username}-public-subnet-a', '10.0.0.0/28', 'us-east-1a'),
            (f'{username}-private-subnet-a', '10.0.0.16/28', 'us-east-1a'),
            (f'{username}-public-subnet-b', '10.0.0.32/28', 'us-east-1b'),
            (f'{username}-private-subnet-b', '10.0.0.48/28', 'us-east-1b'),
        ]
        
        for subnet_name, cidr, az in expected_subnets:
            subnets = ec2.describe_subnets(
                Filters=[
                    {'Name': 'tag:Name', 'Values': [subnet_name]},
                    {'Name': 'cidr-block', 'Values': [cidr]},
                    {'Name': 'availability-zone', 'Values': [az]}
                ]
            )
            
            if subnets['Subnets']:
                print(f"✅ Subnet found: {subnet_name}")
            else:
                print(f"❌ Subnet missing: {subnet_name}")
                return False
        
        # Check Internet Gateway
        igws = ec2.describe_internet_gateways(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f'{username}-prod-igw']},
                {'Name': 'attachment.vpc-id', 'Values': [vpc_id]}
            ]
        )
        
        if igws['InternetGateways']:
            print(f"✅ Internet Gateway found and attached")
        else:
            print("❌ Internet Gateway not found or not attached")
            return False
        
        print("\n🎉 Lab 4 validation completed successfully!")
        return True
        
    except Exception as e:
        print(f"❌ Validation error: {str(e)}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 validate-lab.py <username>")
        sys.exit(1)
    
    username = sys.argv[1]
    success = validate_vpc_lab(username)
    sys.exit(0 if success else 1)
