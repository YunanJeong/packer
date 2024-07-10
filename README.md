# packer

IaC 방식으로 EC2 이미지 만들기

## packer 용도

- AWS AMI뿐만 아니라 Docker 이미지, VMware, VirtualBox, Google Cloud, Azure 등 여러 플랫폼에서 '이미지'라고 불리는 것들을 빌드(pack)할 수 있음
- 당연히 그냥 각 플랫폼의 자체적인 빌드도구를 써도 상관없음
- 특히 docker 이미지는 자체 빌드도구가 강력하고 워낙 널리 쓰이기 때문에 packer 안쓰는게 더 좋아보이기도?
- 이미지를 일관된&자주 쓰는 IaC 형식으로 관리하고자 할 때 packer가 유용한 것

## install

```sh
# Linux
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer
```

## json or HCL

- packer 템플릿은 json 또는 HCL로 가능
- 포맷만 다를뿐 거의 동일한 내용으로 작성됨
- 둘 다 많이 쓰이지만 HCL로 쓰는 게 더 최신 사양이고 일부 부가기능 더 있음
- HCL이 더 human-level이라 쓰고 유지보수하기도 낫다.
- `.pkr.hcl`은 HCL로 쓰인 packer 템플릿의 전용 확장자
- json은 그냥 `.json`

## packer로 AWS AMI 만들 때 테스트 방법

- terraform이랑 비슷
- 인스턴스 띄우고, inline 쉘스크립트 실행되고, 필요한 앱들이 정상설치되고, ... 전체 실행 지켜봐야 됨
- 템플릿을 여러 개 작성해놓고, 각 인스턴스를 동시에 병렬로 띄워서 테스트해보는 것이 요령이라면 요령
- github action, CI/CD 도구 등등이 있지만, 결국 한참기다려야하는 건 같음!
