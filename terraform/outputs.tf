output "rds_endpoint" {
  value = aws_db_instance.wagtail_db.endpoint
}

output "s3_bucket" {
  value = aws_s3_bucket.wagtail_media.id
}
