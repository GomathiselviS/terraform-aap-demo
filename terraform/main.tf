terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "tf-demo-aws-ec2-instance-a" {
  ami           = "ami-06fba29f5013a0eb2"
  instance_type = "t2.micro"
  tags = {
    Name = "tf-demo-aws-ec2-instance-a"
  }
}
