terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.44"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}


# Used to get access to the effective account and user that Terraform
# is running as. Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {}


resource "aws_key_pair" "authorized_key" {
  key_name   = var.ec2_key_name
  public_key = var.ec2_key
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
