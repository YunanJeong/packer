# packer

IaC 방식으로 EC2 이미지 만들기

## packer 용도

- AWS AMI뿐만 아니라 Docker 이미지, VMware, VirtualBox, Google Cloud, Azure 등 여러 플랫폼에서 '이미지'라고 불리는 것들을 빌드(pack)할 수 있음
  - 당연히 그냥 각 플랫폼 자체 빌드도구를 써도 상관없음
  - 특히 docker 이미지는 자체 빌드도구가 강력하고 워낙 널리 쓰이기 때문에 packer 안쓰는게 더 좋아보이기도? 애초에 docker는 DockerFile 텍스트로 표현이 되니까
- 이미지를 일관된 IaC 방식으로 관리&공유할 때 packer가 유용한 것
  - ami를 타 계정, 타 유저에게 공유하기 좋음
  - 특히, 요즘은 `IaC와 LLM이 시너지가 참 좋은 듯`. 인프라 주제로 대화시, 규격화된 코드로 처리하다보니 간결하고 오류도 적다.
- packer는 이미지 빌드만 수행하고, 이후 관리는 관여치 않는다. 빌드 후 이미지 확인, 실행, 삭제 등은 각 개별 플랫폼에서 수행해야 한다.
- packer로 이미지 빌드시, 해당 플랫폼의 사전설치가 요구될 수 있음
  - docker 이미지: docker 런타임 설치 필요
  - AWS-ami: awscli 있으면 편한데 없어도되고, credentials는 필요

## install

```sh
# Linux
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer
```

## json vs. HCL

- packer 템플릿은 json 또는 HCL로 가능
- 포맷만 다를 뿐 거의 동일한 내용으로 작성됨
- 둘 다 많이 쓰이지만 HCL이 더 최신 사양이고 일부 부가기능 더 있음
- HCL이 더 human-level이라 쓰고 유지보수하기도 낫다.
- `.pkr.hcl`은 HCL로 쓰인 packer 템플릿의 전용 확장자
- json은 그냥 `.json`

## packer로 AWS AMI 만들 때 테스트 방법

- terraform이랑 비슷
- 인스턴스 띄우고, inline 쉘스크립트 실행되고, 필요한 앱들이 정상설치되고, ... 전체 실행 지켜봐야 됨
- `packer validate {템플릿}`, `packer inspect {템플릿}`으로 syntax,메타데이터 등을 사전체크 가능
- 템플릿을 여러 개 작성해놓고, 각 인스턴스를 동시에 병렬로 띄워서 테스트해보는 것이 요령이라면 요령
- github action, CI/CD 도구 등 여러 가지 있지만, 결국 최종확인을 위해선 한참 기다려야하는 건 같음!

## 커맨드

```sh
# 초기화. packer 블록에 지정된 플러그인 다운로드
packer init template.pkr.hcl

# 템플릿 indent 업데이트 (가독성, 일관성 개선)
packer fmt template.pkr.hcl

# syntax 및 설정 검증
packer validate template.pkr.hcl

# variables 할당, 메타데이터 검증
packer inspect template.pkr.hcl
```

```sh
# 빌드
packer build template.pkr.hcl
```
