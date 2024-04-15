terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    google = {
      source = "hashicorp/google"
      version = "5.12.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"
}

variable "key_pair" {
  type= string
  sensitive= true
}

resource "local_sensitive_file" "id_rsa" {
  content  = var.key_pair
  filename = "~/.ansible-test_id_rsa"
}

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true
}

# Create a public subnet for bastion
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.1.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf_demo"
  }
}

# Create security group for bastion
resource "aws_security_group" "sec_grp" {
  name        = "ansible-test-sg"
  description = "security group for bastion"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "tf_demo"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sec_ingress_rule1" {
  security_group_id = aws_security_group.sec_grp.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "sec_ingress_rule2" {
  security_group_id = aws_security_group.sec_grp.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}

resource "aws_vpc_security_group_egress_rule" "sec_egress_rule" {
  security_group_id = aws_security_group.sec_grp.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "tf_demo_aws_ec2_instance_a" {
  ami           = "ami-00868b88dcd97faed"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_subnet.id
  key_name = "ansible-test-key"
  ebs_optimized = true
  vpc_security_group_ids = [aws_security_group.sec_grp.id]
  associate_public_ip_address = true
  user_data = file("install.sh")
  tags = {
    Name = "tf_demo_aws_ec2_instance_a"
  }
}

variable "gcp_credentials" {
  type= string
}
variable "gcp_project" { type= string }

provider "google" {
  credentials = var.gcp_credentials
  project = var.gcp_project
  region = "northamerica-northeast1"
}

resource "google_compute_instance" "tf-demo-gcp-instance-a" {
  name         = "tf-demo-gcp-instance-a"
  machine_type = "e2-micro"
  zone = "northamerica-northeast1-a"

  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20240110"
      labels = {
        my_label = "value"
      }
    }
  }

network_interface {
    network = "default"
  }
}
