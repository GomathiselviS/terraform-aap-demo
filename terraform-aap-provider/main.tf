terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.44.0"
    }
    aap = {
      source = "ansible/aap"
    }

  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "tf-demo-aws-ec2-instance-b" {
  ami           = "ami-0005e0cfe09cc9050"
  instance_type = "t2.micro"
  tags = {
    Name = "tf-demo-aws-ec2-instance-b"
  }
}

provider "aap" {
  host     = "https://localhost:8043"
  username = "ansible"
  password = "test123!"
  insecure_skip_verify = true
}

resource "aap_group" "tf-demo-group" {
  inventory_id = 2
  name         = "tf_group"
  variables = jsonencode(
    {
      "username" : "admin"
    }
  )
}

resource "aap_host" "tf-demo-aws-ec2-instance-b" {
  inventory_id = 2
  name = "aws_instance_tf-demo-aws-ec2-instance-b"
  description = "An EC2 instance created by Terraform"
  groups = [aap_group.tf-demo-group.id]
  variables = jsonencode(aws_instance.tf-demo-aws-ec2-instance-b)
}
