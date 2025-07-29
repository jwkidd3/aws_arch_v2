# Outputs with variables
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "website_url" {
  description = "URL to access the website"
  value       = "http://${aws_instance.web_server.public_ip}"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.terraform_bucket.bucket
}

output "resource_summary" {
  description = "Summary of created resources"
  value = {
    instance_id   = aws_instance.web_server.id
    instance_type = aws_instance.web_server.instance_type
    bucket_name   = aws_s3_bucket.terraform_bucket.bucket
    environment   = var.environment
    owner         = var.username
  }
}
