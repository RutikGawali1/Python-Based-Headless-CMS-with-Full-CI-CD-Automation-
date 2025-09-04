variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Existing EC2 key pair name to SSH"
  type        = string
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "wagtail-free"
}
