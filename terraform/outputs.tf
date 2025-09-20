# --- Outputs ---
output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.app_host.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of EC2 instance"
  value       = aws_instance.app_host.public_dns
}

output "app_url" {
  description = "Wagtail CMS URL"
  value       = "http://${aws_instance.app_host.public_dns}"
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.repo.repository_url
}

output "s3_bucket_name" {
  description = "S3 bucket for media storage"
  value       = aws_s3_bucket.media.bucket
}