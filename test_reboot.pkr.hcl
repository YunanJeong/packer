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
    ami  = "ami-04a81a99f5ec58529" # us-east-1  # "ami-063454de5fe8eba79" # ap-northeast-2
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

  # 최종 결과물 ami 설정 (참고: ami_name과 ami의 tag Name은 다른 개념)
  ami_name = "ami-${var.tags.Name}"
  tags     = var.tags

  # 임시 인스턴스 볼륨 설정 (미설정시 default)
  launch_block_device_mappings {
    device_name           = "/dev/sda1" # 필수입력 값
    volume_size           = 8           # GB. 미할당시 default 8GB # ami의 기본 볼륨으로 그대로 적용됨 # 첫 작업시 넉넉하게 잡되, 결과물 확인후 최적화
    volume_type           = "gp2"       # 미할당시 default
    delete_on_termination = true        # 미할당시 default false. terraform과 다르게 false가 default라 미설정하고 packer작업시 EBS 내역이 계속 쌓임 
  }
  # 최종 결과물 AMI의 볼륨 설정 (미설정시 원본 AMI의 설정값을 따름)
  ami_block_device_mappings {
    device_name = "/dev/sda1" # 필수입력 값
    volume_type = "gp3"       # launch에서 사용한 볼륨을 그대로 가져오되, gp3로 변경 (사이즈 변경 같은건 안됨) 
  }
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
    # true: 중간에 disconnect되면 즉시 정상종료하고 해당 시점까지 작업내역을 이미지로 저장
    # false: disconnect 즉시 에러 취급하고 이미지 미생성 
    expect_disconnect = true 
    
    inline = [
      "echo 11111111111111111",
      "sudo reboot",  # 재부팅이 필요한 경우 (예시: 드라이버 설치 후 적용)
      "echo 22222222222222222",
    ]
    pause_after = "20s"  # 이 provisioner의 작업을 끝낸 후, 20초 대기. 안정적인 재부팅 핸들링을 위함
  }
  provisioner "shell" {
    pause_before        = "20s" # 이 provisioner의 작업 시작 전, 20초 대기. 안정적인 재부팅 핸들링을 위함
    start_retry_timeout = "5m"  # 재부팅 등 상황에서 timeout 시간
    inline = [
      "echo 33333333333333333",
    ]
  }
}