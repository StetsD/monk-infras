provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = var.monk_state_bucket
    key = concat(var.monk_state_path, "srv/terraform.tfstate")
    region = var.monk_state_bucket_reg
  }
}

resource "aws_key_pair" "key_pair_master" {
  key_name = "ansible_master"
  public_key = file(var.ssh_public_key_path)
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.monk_state_bucket
    key = concat(var.monk_state_path, "network/terraform.tfstate")
    region = var.monk_state_bucket_reg
  }
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
  vpc_security_group_ids = [aws_security_group.monk_sg.id]
  key_name = aws_key_pair.key_pair_master.key_name
  tags = {
    Name = "monk-instance-master"
  }
}

resource "aws_security_group" "monk_sg" {
  name = "Monk SG"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

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
    cidr_blocks = [concat(var.work_machine_ip), "/32"]
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