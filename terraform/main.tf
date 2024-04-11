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

resource "aws_instance" "tf-demo-aws-ec2-instance-a" {
  ami           = "ami-00868b88dcd97faed"
  instance_type = "t2.micro"
  tags = {
    Name = "tf-demo-aws-ec2-instance-a"
  }
}

variable "gcp_credentials" { type= string }
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
