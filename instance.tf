provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "mustbestd"
    key = "dev/states/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "ubuntu_latest" {
  owners = ["099720109477"]
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "key_pair_master" {
  key_name = "ansible_master"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "monk_instance" {
  ami = var.monk_ami != "" ? var.monk_ami : data.aws_ami.ubuntu_latest.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.monk_sg.id]
  key_name = aws_key_pair.key_pair_master.key_name
  tags = {
    Name = "monk-instance-master"
  }
}

resource "aws_security_group" "monk_sg" {
  name = "Monk SG"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.work_machine_ip}/32"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monk-sg"
    Owner = "Boris Britva"
  }
}