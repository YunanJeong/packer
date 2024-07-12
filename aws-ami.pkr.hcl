packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# variable을 별도 선언하면 inspect, 로그 등에서 확인이 용이함. 딱히 안써도됨. 
variable "aws_access_key" {
  default = env("AWS_ACCESS_KEY") # env함수로 환경변수 읽기가능
}
variable "aws_secret_key" {
  default = env("AWS_SECRET_KEY")
}
variable "ubuntu_22_lts" {
  default = {
    ami  = "ami-063454de5fe8eba79"
    user = "ubuntu"
  }
}

/*
Name = "string-example-{{timestamp}}"  # 현재 타임스탬프를 포함
Name = "string-example-{{uuid}}"       # UUID를 포함
Name = "string-example-{{isotime}}"    # ISO 8601 형식의 현재 시간을 포함
Name = "{{clean_ami_name `string-example-{{isotime}}`}}"  # AMI 이름에서 AWS에서 허용하지 않는 문자를 제거
Name = "string-example-{{build_name}}" # 현재 빌드의 이름을 포함
Name = "string-example-{{build_type}}" # 현재 빌드의 타입을 포함
Name = "string-example-{{user `custom_var`}}" # 사용자 정의 변수를 포함
*/
variable "tags" {
  default = {
    Name    = "yunan-packer-test-{{timestamp}}"
    Owner   = env("TAG_OWNER")
    Service = env("TAG_SERVICE")
    Packer  = true
  }
}

source "amazon-ebs" "example" {
  # AWS 자격증명 설정 (생략시 환경변수 또는 awscli의 default 프로필이 자동적용됨)
  // access_key = var.aws_access_key 
  // secret_key = var.aws_secret_key
  // region     = "ap-northeast-2"
  // profile    = "default" # ~/.aws/credentials에서 프로필 선택 명시

  # ami 생성을 위한 임시 인스턴스 설정
  source_ami    = var.ubuntu_22_lts.ami
  ssh_username  = var.ubuntu_22_lts.user
  instance_type = "c5.large"
  run_tags      = var.tags

  # 결과물 ami 설정 (참고: ami_name과 ami의 tag Name은 다른 개념)
  ami_name = "ami-${var.tags.Name}"
  tags     = var.tags
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
  # packer ami 빌드절차: 임시 인스턴스 실행=>프로비저닝 스크립트 실행=>임시 인스턴스 종료=>이미지 생성
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}