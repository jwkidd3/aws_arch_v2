# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.lab_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.lab_igw.id
}

output "vpc_summary" {
  description = "Summary of VPC resources"
  value = {
    vpc_id              = aws_vpc.lab_vpc.id
    public_subnet_id    = aws_subnet.public_subnet.id
    private_subnet_id   = aws_subnet.private_subnet.id
    internet_gateway_id = aws_internet_gateway.lab_igw.id
  }
}
