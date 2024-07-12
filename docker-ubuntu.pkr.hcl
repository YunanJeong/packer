# packer block: 이미지 빌드시 필요한 플러그인 지정
packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
  }
}

# source block: 플러그인에서 정해진 "빌더이름", "빌더유형" 지정
source "docker" "ubuntu" {
  image  = "ubuntu:jammy"
  commit = true
}

# build block: 실행된 후 Packer가 해당 이미지에 대해 수행해야 하는 작업 정의
build {
  name = "learn-packer"
  # source builder: Packer가 특정 환경에서 이미지 생성시 필요한 구성요소
  sources = [
    "source.docker.ubuntu"
  ]
}
