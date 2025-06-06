terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.region
  # access_key = "aws-access-key"
  # secret_key = "aws-secret-key"
}

data "aws_key_pair" "existing_ec2_key_pair" {
  # IMPORTANT: Replace "my-existing-key-name" with the actual name
  # of your SSH key pair as it appears in the AWS EC2 Key Pairs console.
  key_name = "demo"
}

# Create an instance
resource "aws_instance" "web" {
  ami                    = var.ami-id
  instance_type          = var.instance_type
  key_name               = data.aws_key_pair.existing_ec2_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.example.id]

  tags = {
    Name = "Terraform-Ansible"
  }

  provisioner "local-exec" {
    command = "echo [webserver] > ../ansible/hosts.ini && echo ${aws_instance.web.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=demo.pem >> ../ansible/hosts.ini"
  }

}

# Create a security group
resource "aws_security_group" "example" {
  # ... other configuration ...

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "public_ip" {
  value = aws_instance.web.public_ip
}
output "private_ip" {
  value = aws_instance.web.private_ip
}
