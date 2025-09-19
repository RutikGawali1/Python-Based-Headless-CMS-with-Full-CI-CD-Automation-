output "ec2_public_ip" {
  value = aws_instance.app_host.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.app_host.public_dns
}

output "jenkins_url" {
  value = "http://${aws_instance.app_host.public_dns}:8080"
}

output "app_url" {
  value = "http://${aws_instance.app_host.public_dns}:30080"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.repo.repository_url
}

output "s3_bucket_name" {
  value = aws_s3_bucket.media.bucket
}
