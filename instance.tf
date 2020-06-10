provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "amazon_latest" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "monk_instance" {
  ami = var.monk_ami != "" ? var.monk_ami : data.aws_ami.amazon_latest.id
  instance_type = "t3.micro"
  vpc_security_group_ids = []
}