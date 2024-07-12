packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_access_key" {
  default = env("AWS_ACCESS_KEY")
}
variable "aws_secret_key" {
  default = env("AWS_SECRET_KEY")
}
variable "region" {
  default = "ap-northeast-2"
}
variable "source_ami" {
  default = "ami-063454de5fe8eba79"  # Ubuntu 22.04 LTS
}
variable "instance_type" {
  default = "t2.micro"
}
variable "ssh_username" {
  default = "ubuntu"                 # ubuntu
}

source "amazon-ebs" "example" {
  # key, region 미기입시,~/.aws/credentials 파일에 저장된 값 사용됨
  // access_key    = var.aws_access_key
  // secret_key    = var.aws_secret_key
  // region        = var.region
  source_ami    = var.source_ami
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  ami_name      = "packer-example-ami-{{timestamp}}"
}

build {
  name = "learn-packer-aws"
  sources = [
    "source.amazon-ebs.example"
  ]

  # 이미지에 포함될 앱 설치
  # 실제 인스턴스 시작 단계가 아니라, 이미지에 설치&서비스 실행 등이 모두 포함된다.
  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
  }
}