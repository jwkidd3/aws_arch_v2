# Lab 3 Quick Reference Guide

## IAM Best Practices Checklist

### User Management
- ✅ Use groups for permission management
- ✅ Set temporary passwords requiring change
- ✅ Apply principle of least privilege
- ✅ Use meaningful naming conventions

### Policy Design
- ✅ Start with AWS managed policies when possible
- ✅ Use resource-level restrictions
- ✅ Apply conditions for additional security
- ✅ Include explicit deny statements when needed

### Role Configuration
- ✅ Use roles for service-to-service access
- ✅ Configure proper trust relationships
- ✅ Limit role session duration when appropriate
- ✅ Use external ID for cross-account access

## Common IAM Policy Elements

### Basic Structure
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow|Deny",
            "Action": "service:action",
            "Resource": "arn:aws:service:region:account:resource",
            "Condition": {
                "ConditionOperator": {
                    "ConditionKey": "value"
                }
            }
        }
    ]
}
```

### Useful Condition Keys
- `aws:username` - IAM user name
- `aws:userid` - Unique user ID
- `aws:CurrentTime` - Current date/time
- `aws:RequestedRegion` - AWS region
- `ec2:InstanceType` - EC2 instance type
- `s3:prefix` - S3 object prefix

### Resource ARN Formats
- S3 Bucket: `arn:aws:s3:::bucket-name`
- S3 Object: `arn:aws:s3:::bucket-name/*`
- EC2 Instance: `arn:aws:ec2:region:account:instance/*`
- IAM Role: `arn:aws:iam::account:role/role-name`

## Troubleshooting Commands

### Check Current Identity
```bash
aws sts get-caller-identity
```

### List S3 Buckets
```bash
aws s3 ls
```

### Describe EC2 Instances
```bash
aws ec2 describe-instances --region us-east-1
```

### Simulate Policy
```bash
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::account:user/username \
    --action-names s3:GetObject \
    --resource-arns arn:aws:s3:::bucket-name/object-key
```

