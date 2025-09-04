terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# --- Default VPC & subnets ---
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- IAM role for EC2 to access ECR/S3 ---
data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
}

# Inline policy: ECR full, S3 basic (adjust as needed)
data "aws_iam_policy_document" "ec2_policy" {
  statement {
    actions = [
      "ecr:*",
      "cloudwatch:*",
      "logs:*",
      "ec2:Describe*",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_inline" {
  name   = "${var.project_name}-ec2-policy"
  policy = data.aws_iam_policy_document.ec2_policy.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_inline.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# --- Security Group (22 SSH, 8080 Jenkins, 30080 app) ---
resource "aws_security_group" "sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH, Jenkins and NodePort"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "App NodePort"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- ECR repo for your image ---
resource "aws_ecr_repository" "repo" {
  name = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
}

# --- S3 bucket (media later if needed) ---
resource "aws_s3_bucket" "media" {
  bucket = "${var.project_name}-media-${random_id.rand.hex}"
}

resource "random_id" "rand" {
  byte_length = 4
}

# --- EC2 instance (t2.micro free-tier) ---
data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "ci_host" {
  ami                    = data.aws_ami.amzn2.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  tags = { Name = "${var.project_name}-ci-host" }

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    # Update
    yum update -y

    # Install Docker
    amazon-linux-extras install docker -y || yum install -y docker
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user

    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    yum install -y unzip
    unzip -q awscliv2.zip
    ./aws/install

    # Install k3s (single-node Kubernetes)
    curl -sfL https://get.k3s.io | sh -
    # k3s installs kubectl as /usr/local/bin/kubectl and kubeconfig at /etc/rancher/k3s/k3s.yaml
    chmod 644 /etc/rancher/k3s/k3s.yaml

    # Install Jenkins (LTS)
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    yum install -y java-17-amazon-corretto-headless jenkins git
    systemctl enable jenkins
    systemctl start jenkins

    # Allow jenkins user to run docker & kubectl
    usermod -aG docker jenkins

    # Print where to find Jenkins initial admin password on login
    echo "Jenkins password in: /var/lib/jenkins/secrets/initialAdminPassword" > /root/INFO.txt
  EOF
}
