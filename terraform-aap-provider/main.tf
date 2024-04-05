terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }

    aap = {
      source = "ansible/aap"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "tf-demo-aws-ec2-instance-2" {
  ami           = "ami-0005e0cfe09cc9050"
  instance_type = "t2.micro"
  tags = {
    Name = "tf-demo-aws-ec2-instance-2"
  }
}

provider "google" {
  region = "northamerica-northeast1"
}

resource "google_compute_instance" "tf-demo-gcp-instance-2" {
  name         = "tf-demo-gcp-instance-2"
  machine_type = "e2-micro"
  zone = "northamerica-northeast1-a"

  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20240110"
    }
  }

  network_interface {
    network = "default"
  }
}

provider "aap" {
  host     = "https://localhost:8043"
  username = "ansible"
  password = "test123!"
  insecure_skip_verify = true
}

resource "aap_host" "tf-demo-aws-ec2-instance-2" {
  inventory_id = 2
  name = "aws_instance_tf-demo-aws-ec2-instance-2"
  description = "An EC2 instance created by Terraform"
  variables = jsonencode(aws_instance.tf-demo-aws-ec2-instance-2)
}

resource "aap_host" "tf-demo-gcp-instance-2" {
  inventory_id = 2
  name = "google_compute_instance_tf-demo-gcp-instance-2"
  description = "A GCE instance created by Terraform"
  variables = jsonencode(google_compute_instance.tf-demo-gcp-instance-2)
}
