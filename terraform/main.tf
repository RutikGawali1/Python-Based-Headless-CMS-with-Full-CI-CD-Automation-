provider "aws" {
  region = "us-east-1"
}

# S3 bucket for media/static files
resource "aws_s3_bucket" "wagtail_media" {
  bucket = "wagtail-project-media-12345"
  acl    = "private"
}

# RDS PostgreSQL
resource "aws_db_instance" "wagtail_db" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  name                 = "wagtaildb"
  username             = "wagtail"
  password             = "wagtailpassword"
  publicly_accessible  = false
  skip_final_snapshot  = true
}
