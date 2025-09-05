variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "wagtail-free"
}

variable "key_name" {
  description = "EC2 key pair name for SSH"
  type        = string
}
