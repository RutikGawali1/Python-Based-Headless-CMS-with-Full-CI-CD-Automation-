output "ec2_public_ip" {
  value = aws_instance.ci_host.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.ci_host.public_ip}:8080"
}

output "app_url" {
  value = "http://${aws_instance.ci_host.public_ip}:30080"
}

output "ecr_repo_uri" {
  value = aws_ecr_repository.repo.repository_url
}

output "s3_bucket" {
  value = aws_s3_bucket.media.bucket
}
