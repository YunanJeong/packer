packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
  default = "us-west-2"
}
variable "source_ami" {
  default = "ami-0c55b159cbfafe1f0"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "ssh_username" {
  default = "ec2-user"
}

source "amazon-ebs" "example" {
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  region        = var.region
  source_ami    = var.source_ami
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  ami_name      = "packer-example-ami-{{timestamp}}"
}

build {
  name    = "learn-packer-aws"
  sources = [
    "source.amazon-ebs.example"
  ]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
  }
}