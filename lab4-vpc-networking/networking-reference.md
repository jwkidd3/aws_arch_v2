# VPC Networking Reference

## CIDR Block Planning

### Main VPC: 10.0.0.0/26 (64 total IPs)
- Network: 10.0.0.0
- Broadcast: 10.0.0.63
- Usable IPs: 10.0.0.1 - 10.0.0.62
- Total usable: 62 IPs (AWS reserves 5 IPs per subnet)

### Subnet Breakdown:
1. **Public Subnet A (us-east-1a):** 10.0.0.0/28
   - Range: 10.0.0.0 - 10.0.0.15 (16 IPs)
   - Usable: 10.0.0.4 - 10.0.0.14 (11 IPs)
   - Reserved by AWS: .0, .1, .2, .3, .15

2. **Private Subnet A (us-east-1a):** 10.0.0.16/28
   - Range: 10.0.0.16 - 10.0.0.31 (16 IPs)
   - Usable: 10.0.0.20 - 10.0.0.30 (11 IPs)
   - Reserved by AWS: .16, .17, .18, .19, .31

3. **Public Subnet B (us-east-1b):** 10.0.0.32/28
   - Range: 10.0.0.32 - 10.0.0.47 (16 IPs)
   - Usable: 10.0.0.36 - 10.0.0.46 (11 IPs)
   - Reserved by AWS: .32, .33, .34, .35, .47

4. **Private Subnet B (us-east-1b):** 10.0.0.48/28
   - Range: 10.0.0.48 - 10.0.0.63 (16 IPs)
   - Usable: 10.0.0.52 - 10.0.0.62 (11 IPs)
   - Reserved by AWS: .48, .49, .50, .51, .63

## AWS Reserved IP Addresses

In each subnet, AWS reserves 5 IP addresses:
- **First IP (.0):** Network address
- **Second IP (.1):** VPC router
- **Third IP (.2):** DNS server
- **Fourth IP (.3):** Reserved for future use
- **Last IP:** Network broadcast address

## Route Table Configuration

### Public Route Table
| Destination | Target | Purpose |
|-------------|--------|---------|
| 10.0.0.0/26 | Local | VPC internal traffic |
| 0.0.0.0/0 | Internet Gateway | Internet access |

### Private Route Table
| Destination | Target | Purpose |
|-------------|--------|---------|
| 10.0.0.0/26 | Local | VPC internal traffic |
| 0.0.0.0/0 | NAT Gateway | Outbound internet access |

## Network Flow Paths

### Public Subnet Internet Access (Bidirectional)
```
Internet ↔ Internet Gateway ↔ Public Subnet
```

### Private Subnet Internet Access (Outbound Only)
```
Private Subnet → NAT Gateway (in Public Subnet) → Internet Gateway → Internet
```

### VPC Internal Communication
```
Any Subnet ↔ Local Routes ↔ Any Subnet (within VPC)
```

## Security Considerations

1. **Public Subnets:** 
   - Resources get public IPs
   - Directly accessible from internet
   - Use security groups to control access

2. **Private Subnets:**
   - No public IPs assigned
   - Not directly accessible from internet
   - Can access internet via NAT Gateway

3. **NAT Gateway:**
   - Provides outbound internet access for private subnets
   - Stateful (allows return traffic)
   - Managed by AWS (highly available)

## Cost Considerations

- **VPC, Subnets, Route Tables, Internet Gateway:** Free
- **NAT Gateway:** Charged per hour + data processing
- **Elastic IP:** Free when associated, charged when unassociated
- **Data Transfer:** Charges apply for data out to internet

## Best Practices

1. **Subnet Design:** Plan CIDR blocks carefully to avoid conflicts
2. **Multi-AZ:** Distribute subnets across multiple AZs for HA
3. **Security:** Use private subnets for databases and internal services
4. **Naming:** Use consistent naming conventions with prefixes
5. **Documentation:** Maintain network diagrams and IP allocation records

