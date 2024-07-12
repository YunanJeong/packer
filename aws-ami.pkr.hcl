packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_access_key" {
  default = env("AWS_ACCESS_KEY") # env함수로 환경변수 읽기가능
}
variable "aws_secret_key" {
  default = env("AWS_SECRET_KEY")
}
variable "region" {
  default = "ap-northeast-2"
}
variable "source_ami" {
  default = "ami-063454de5fe8eba79" # Ubuntu 22.04 LTS
}
variable "instance_type" {
  default = "t2.micro"
}
variable "ssh_username" {
  default = "ubuntu"
}

source "amazon-ebs" "example" {
  # key, region 미기입시,~/.aws/credentials 파일에 저장된 값 사용됨
  // access_key    = var.aws_access_key
  // secret_key    = var.aws_secret_key
  // region        = var.region
  source_ami    = var.source_ami
  instance_type = var.instance_type
  ssh_username  = var.ssh_username
  ami_name      = "yunan-packer-test-ami-{{timestamp}}"
  // ami_name = "packer-example-{{timestamp}}"  # 현재 타임스탬프를 포함
  // ami_name = "packer-example-{{uuid}}"       # UUID를 포함
  // ami_name = "packer-example-{{isotime}}"    # ISO 8601 형식의 현재 시간을 포함
  // ami_name = "{{clean_ami_name `packer-example-{{timestamp}}`}}"  # AMI 이름에서 AWS에서 허용하지 않는 문자를 제거
  // ami_name = "packer-example-{{build_name}}" # 현재 빌드의 이름을 포함
  // ami_name = "packer-example-{{build_type}}" # 현재 빌드의 타입을 포함
  // ami_name = "packer-example-{{user `custom_var`}}" # 사용자 정의 변수를 포함
}


build {
  # 빌드 블록이 여러 개 있을 시 식별용 이름(이미지 이름 아님)
  name = "my-ami-builder"
  # 소스 빌더 지정
  sources = [
    # AWS AMI 생성시 일반적인 소스빌더(거의 이것만 쓴다고 생각해도 무방)  
    # EBS 볼륨기반으로 AMI를 생성 (EBS기반이 아니면 데이터 보존이 안됨)
    "source.amazon-ebs.example"
  ]

  # 이미지에 포함될 앱 설치 & 서비스 실행 등 설정
  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
  }
}