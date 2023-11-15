terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = "eu-west-2"
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
resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  count=3
  key_name = "user13_deployer-key"
  tags = {
    Name = "user13-instance-${count.index}",
    role=count.index==0?"lb": (count.index<3?"user13-web":"user13-backend")
  }
}
output "ips"{
  value = aws_instance.instance.*.public_ip
}
