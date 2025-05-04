terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "example" {
  ami           = "ami-066734adba283ab4b"
  instance_type = "t2.micro"
  subnet_id     = "subnet-0735eb271081130a3"

  tags = {
    Name = "terraform-example"
  }
}

