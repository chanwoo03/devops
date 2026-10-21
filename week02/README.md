# 2주차 - 실습 환경 구축과 버전 관리 기초

## 1. 핵심 개념

서버는 클라이언트의 요청(Request)을 받아 서비스나 데이터를 응답(Response)하는 주체임. 문맥에 따라 서버 컴퓨터 또는 서버 프로그램을 의미함.

- 베어메탈 : 물리 장비에 OS를 설치하여 프로그램을 실행하는 방식임
- 가상 머신(VM) : 하이퍼바이저가 자원을 가상화하며 VM마다 게스트 OS와 커널을 가짐
- 컨테이너 : 커널을 공유하면서 프로세스와 실행 환경을 격리함. 일반적으로 VM보다 가벼움
- 커널 : CPU, 메모리 등 하드웨어 자원을 관리하고 시스템 콜을 제공함
- WSL2 : Windows에서 Linux 환경을 사용할 수 있게 해줌

## 2. WSL2 설치와 실행

Windows PowerShell에서 입력함. 설치 시 관리자 권한과 재부팅이 필요할 수 있음.

```powershell
# 설치된 배포판과 실행 상태, WSL 버전 확인
# -l: list, -v: verbose
wsl -l -v

wsl --install

# 인터넷에서 설치할 수 있는 배포판 목록 확인
wsl --list --online

# 특정 배포판 설치
wsl --install -d Ubuntu-24.04

# 앞으로 설치할 배포판의 기본 WSL 버전 설정
wsl --set-default-version 2

# 이미 설치된 배포판을 WSL2로 변경
wsl --set-version Ubuntu-24.04 2

# 기본 실행 배포판 설정
wsl --set-default Ubuntu-24.04

# 지정한 배포판 실행
wsl -d Ubuntu-24.04
```

Ubuntu 셸에서 아래 명령을 입력하면 PowerShell로 돌아감.

```bash
exit
```

배포판 이름은 `wsl -l -v`에서 확인한 실제 이름을 사용함. 초기 계정 생성 시 비밀번호 입력은 화면에 표시되지 않음.

## 3. Ubuntu 작업 공간과 패키지

아래 명령은 WSL Ubuntu 터미널에서 입력함.

```bash
cd ~

# 필요한 상위 폴더까지 함께 생성
mkdir -p ~/devops/week02

cd ~/devops
pwd

# 패키지 목록 갱신
sudo apt update

# Git과 GitHub CLI 설치
sudo apt install -y git gh
```

- `sudo` : 관리자 권한으로 명령 실행

## 4. 기본 명령어

- `pwd`, `cd 경로` : 현재 위치 확인 / 위치 이동
- `ls`, `ls -l`, `ls -a` : 목록 / 상세 정보 / 숨김 항목 포함
- `mkdir -p 경로` : 필요한 상위 폴더까지 생성
- `rmdir 경로` : 비어 있는 폴더 삭제
- `touch 파일` : 빈 파일 생성 또는 수정 시각 갱신
- `cp 원본파일 대상파일` : 파일 복사
- `mv 원본파일 대상파일` : 이동 또는 이름 변경
- `rm 파일` : 파일 삭제. 대상 경로를 먼저 확인해야 함
- `cat 파일`, `less 파일` : 전체 내용 / 긴 내용 나누어 보기
- `head -n 5 파일`, `tail -n 5 파일` : 앞 / 뒤 5줄 확인
- `tail -f 로그파일` : 추가되는 로그를 계속 확인. Ctrl+C로 종료
- `whoami`, `id` : 현재 사용자 / 사용자와 그룹 정보
- `uname -a`, `cat /etc/os-release` : 커널 / Linux 배포판 정보
- `df -h`, `free -h` : 디스크 / 메모리 사용 상태
- `history`, `!!`, `!ls` : 입력 이력 / 직전 명령 재실행 / 최근 ls 명령 재실행

`>`는 기존 내용을 덮어쓰고, `>>`는 끝에 추가함.

`.`은 현재 위치, `..`은 상위 위치, `~`는 홈, `/`는 루트임.

## 5. Git 기본 흐름

Git은 변경 이력을 로컬에 기록하는 버전 관리 도구임. GitHub는 저장소 공유와 협업을 지원하는 서비스임.

```text
작업 디렉터리 → git add → 스테이징 영역 → git commit → 로컬 저장소
로컬 저장소 → git push → GitHub 원격 저장소
```

```bash
git config --global user.name "본인 이름"
git config --global user.email "본인 이메일"
git config --global init.defaultBranch main

# git config: Git 설정 확인 또는 변경
# --global: 현재 사용자 계정의 모든 Git 저장소에 적용
# init.defaultBranch: 새 저장소의 기본 브랜치 이름 설정

cd ~/devops
git init

# Git 상태 확인
git status

git add week02/README.md

# 커밋 메시지와 함께 기록
git commit -m "docs: 2주차 학습 내용 정리"

git log --oneline
```

- `git add` : 다음 커밋에 포함할 변경사항 선택
- `git commit` : 스테이징된 변경사항을 하나의 버전으로 기록
- `git status` : 현재 브랜치와 변경 상태 확인
- `git diff 이전커밋 이후커밋` : 두 버전 비교. `+`는 추가, `-`는 삭제된 내용임

## 6. 브랜치와 이전 버전 확인

```bash
git switch -c feature/practice
git branch
git switch main
git log --oneline --all --graph

# 실제 커밋 해시를 확인한 뒤 사용
# git switch -d 커밋해시

# 확인 후 main으로 복귀
git switch main
```

브랜치는 특정 커밋을 가리키는 이름이며 작업 흐름을 나누는 데 사용함. `git switch -d`는 특정 커밋으로 이동할 때 사용함.

## 7. GitHub 연결과 공개 저장소

```bash
# GitHub 로그인
gh auth login

# 로그인 상태 확인
gh auth status

cd ~/devops

# 커밋이 있는 상태에서 본인 저장소 이름으로 실행
# gh repo create 저장소이름 --public --source=. --remote=origin --push

# 브라우저에서 저장소 확인
gh repo view --web

# 커밋 업로드
git push
```

gh는 터미널에서 GitHub 기능을 사용하는 명령어 도구임.
