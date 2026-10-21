# 4주차 - 자동화와 협업

## 1. 경로

- 절대 경로 : `/`부터 시작하는 전체 경로
- 상대 경로 : 현재 위치를 기준으로 한 경로
- `~` : 사용자 홈
- `/etc` : 시스템과 프로그램 설정
- `/var/log` : 시스템과 서비스 로그
- `/tmp` : 임시 파일
- `/usr/bin` : 주요 명령어

## 2. 파일과 내용 찾기

```bash
# 셸 스크립트 파일 찾기
find . -type f -name "*.sh"

# 폴더 찾기
find . -type d

# ERROR가 포함된 줄을 줄 번호와 함께 출력
grep -n "ERROR" server.log

# 대소문자 구분 없이 검색
grep -i "error" server.log

# 일치하는 줄 수 출력
grep -c "ERROR" server.log

# INFO가 없는 줄 출력
grep -v "INFO" server.log

# 하위 폴더까지 검색하고 오류 출력 숨김
grep -R -n "exit 1" week03 2>/dev/null

# ERROR가 포함된 줄 수 확인
grep "ERROR" server.log | wc -l

# 검색 결과를 파일에 저장
grep "ERROR" server.log > errors.txt
```

- `find` : 조건에 맞는 파일이나 폴더 검색
- `-type f`, `-type d` : 파일 / 폴더 검색
- `-name "*.sh"` : .sh로 끝나는 이름 검색
- `grep` : 패턴이 들어간 줄 검색
- `-n` : 줄 번호 표시
- `-i` : 대소문자 무시
- `-c` : 일치하는 줄 수 표시
- `-v` : 패턴이 없는 줄 표시
- `-R` : 하위 폴더까지 검색
- `|` : 앞 명령의 출력을 뒤 명령의 입력으로 전달
- `wc -l` : 줄 수 확인. 파일 개수와는 다름
- `2>/dev/null` : 오류 출력 숨김

## 3. 변수와 조건문

```bash
USERNAME="홍길동"
TODAY=$(date +%Y%m%d)
echo "${USERNAME}: backup_${TODAY}.tar.gz"
```

변수 대입 시 `=` 양옆에 공백을 넣으면 안 됨. 값을 사용할 때는 `$`를 붙임.

```bash
#!/bin/bash
FILE="$1"

if [ -z "$FILE" ]; then
  echo "파일명을 입력하세요." >&2
  exit 1
fi

if [ -f "$FILE" ]; then
  echo "파일임"
elif [ -d "$FILE" ]; then
  echo "폴더임"
else
  echo "대상이 없음" >&2
  exit 1
fi
```

- `-f`, `-d` : 일반 파일 / 폴더인지 확인
- `-z`, `-n` : 문자열이 비었는지 / 값이 있는지 확인
- `-eq`, `-ne` : 정수가 같음 / 다름
- `-gt`, `-lt` : 큼 / 작음
- `-ge`, `-le` : 크거나 같음 / 작거나 같음
- `!` : 조건을 반대로 판단

`[`와 `]` 안쪽에는 공백이 필요함.

## 4. 반복문

```bash
for i in $(seq 1 100); do
  mkdir -p "test/dir$i"
done
```

1부터 100까지 반복하면서 폴더를 생성함.

```bash
for f in *.sh; do
  echo "스크립트: $f"
done
```

현재 폴더의 .sh 파일 이름을 출력하는 예시임.

## 5. 프로세스

- 프로그램 : 저장된 실행 코드
- 프로세스 : 실행 중인 프로그램
- PID : 프로세스 번호
- `ps aux` : 프로세스 목록 확인
- `sleep 300 &` : 300초 대기를 백그라운드에서 실행
- `jobs` : 현재 셸의 작업 확인
- `kill PID` : 종료 요청. 기본 SIGTERM임
- `kill -9 PID` : 강제 종료. 정상 종료가 안 될 때 사용함
- `Ctrl+C` : 실행 중인 전경 작업에 SIGINT를 보냄

## 6. 백업과 복원

```text
원본 확인 → 백업 폴더 생성 → 압축 → 성공 확인 → 복원 → 원본과 비교
```

```bash
SOURCE_DIR=${1:-test}
TODAY=$(date +%Y%m%d_%H%M%S)
FILENAME="${TODAY}_$$.tar.gz"
```

- `${1:-test}` : 첫 인자가 없거나 비었으면 test 사용
- `$$` : 현재 셸 PID. 백업 이름이 겹칠 가능성을 줄임
- `tar -czf 백업.tar.gz 원본폴더` : 압축 생성
- `tar -tzf 백업.tar.gz` : 압축 내용 확인
- `tar -xzf 백업.tar.gz -C 복원폴더` : 지정 폴더에 압축 해제
- `du -sh 파일` : 크기 확인
- `diff -rq 원본 복원본` : 폴더 내용 비교

diff 종료 코드는 0이면 같음, 1이면 다름, 2이면 오류임. 백업 후에는 복원한 내용이 원본과 같은지도 확인해야 함.

## 7. .gitignore

```gitignore
week04/backups/
week04/restore-check/
```

백업 결과물과 복원 확인용 폴더를 Git에 추가하지 않도록 설정함.

이미 추적 중인 파일은 자동으로 제외되지 않음. `git rm --cached 파일`로 추적에서 제외할 수 있음.

## 8. 협업 흐름

```text
브랜치 → 수정·확인 → 커밋 → 푸시 → PR → 검토 → Merge
```

```bash
git switch main
git pull --ff-only
git switch -c feature/backup-log

# 코드 작성 및 실행 확인 후
git status
git diff
git add week04/backup.sh
git commit -m "feat: 백업 로그 추가"
git push -u origin feature/backup-log
```

- PR : 변경 내용을 검토하고 합쳐 달라는 요청
- `--ff-only` : 이력이 갈라져 있으면 자동 병합하지 않고 중단
- Squash Merge : 여러 변경을 하나의 커밋으로 합침
- Merge Commit : 기존 이력을 유지하고 병합 커밋을 남김
- Rebase Merge : 작업 커밋을 대상 브랜치 뒤에 새 커밋으로 이어 붙임

## 9. 충돌 해결

같은 부분을 서로 다르게 수정해 자동으로 합칠 수 없을 때 충돌이 발생함.

```bash
# 작업 브랜치에서 실행
git fetch origin
git merge origin/main

# 충돌 파일 수정
