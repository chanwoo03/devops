## 1. 자동화와 실습 구조

셸 스크립트는 반복 명령을 파일에 기록하여 같은 순서로 실행하는 방법. 실행 경로, 권한, 필요한 프로그램, 실패 처리를 함께 정리해야 반복 실행하기 쉽다.

- 셀 스크리브 사용할 땐 ./a.sh 로 명령어 이름만으론 실행이 불가능하다, PATH 지정하면 실행 가능

```
브라우저 localhost:8000
  → Python 웹 앱 chat.py
  → Ollama 서버 127.0.0.1:11434
  → Qwen 모델 qwen3:0.6b
```

- Qwen: chat gpt같은 AI 언어 모델(가벼운 모델임)
- Ollama: 모델을 내려받고 실행하는 서버와 도구

## 2. Ollama 준비와 연결 확인

```bash
sudo apt update
sudo apt install -y python3 curl zstd
curl -fsSL https://ollama.com/install.sh | sh
ollama --version
python3 --version
curl -fsS http://127.0.0.1:11434/api/tags
```

- **`curl`** : URL로 서버에 요청을 보내거나 파일을 내려받는 도구
- **`zstd`** : **Zstandard**의 줄임말로, 파일을 압축하거나 압축을 푸는 도구
- `f` : HTTP 오류가 발생하면 실패로 처리
- `s` : 진행률과 오류 메시지 숨김
- `S` : `s`와 함께 사용해도 오류 메시지는 표시
- `L` : 주소가 다른 주소로 연결되면 따라가기
- `|` : 앞 명령의 출력을 뒤 명령의 입력으로 전달
- `sh` : 전달받은 셸 스크립트 실행

```bash
ollama pull qwen3:0.6b
# 터미널에서 qwen 다운로드
ollama list
curl --max-time 90 -fsS http://127.0.0.1:11434/api/generate \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen3:0.6b","prompt":"한 문장으로 인사해 줘","think":false,"stream":false,"options":{"num_ctx":8192,"num_predict":512}}'
```

- `stream:false`: 응답을 스트림 조각 대신 한 번에 받는다.
- `think:false`: 해당 모델의 생각 모드를 끈다.
- `num_predict`: 생성할 최대 토큰 수 설정.
- `0.6b`: 약 6억 파라미터. 큰 모델은 메모리와 연산 자원을 더 요구한다.

그럼 이 AI는 어디서 실행되고 있는 것인가?

`ollama pull qwen3:0.6b`를 하면 모델 파일(약 523MB)이 내 **컴퓨터 하드디스크**에 다운로드. 기본 위치는 홈 폴더 아래 `.ollama/models` 폴더

[ 컴퓨터 하나 안에서 전부 일어남]
브라우저 → chat.py(8000) → Ollama(11434) → qwen3:0.6b (디스크에서 메모리로 올려서 CPU로 계산)

## 3. Python 앱 실행

```bash
mkdir -p ~/devops/week03/qwen-web
cd ~/devops/week03/qwen-web
# LMS에서 받은 chat.py를 이 디렉터리로 복사한 뒤
python3 chat.py
```

브라우저에서 `http://localhost:8000`에 접속한다. `Ctrl+C`는 실행 중인 Python 웹 앱을 종료하며, 별도로 실행된 Ollama 서버까지 종료하지는 않는다.

`!python3`는 **명령어 기록에서 `python3`로 시작하는 가장 최근 명령을 다시 실행**하는 Bash 문법

## 4. start.sh 핵심 문법

`chat.py`를 실행해 주는 시작 스크립트

```bash
nano start.sh
# nano : 터미널에서 사용하는 텍스트 편집기
#!/bin/bash
# #! = 이 파일을 실행할 때, 바로 뒤에 적힌 프로그램으로 이 파일을 해석하라
# 이 파일은 bash 문법이니 bash로 실행하라
cd "$(dirname "$0")" || exit 1
# 스크립트 경로의 디렉터리 부분 추출을 명령의 표준 출력을 값으로 사용하는 명령 치환을 하고 그것이 실패할 경우 실패 종료 코드로 스크립트를 종료시킨
# 실행 중인 스크립트가 있는 폴더로 이동하고, 이동에 실패하면 종료
exec python3 chat.py
# 현재 셸 프로세스를 Python으로 교체. PID 유지
```

- `$0` : 현재 실행한 스크립트의 이름 또는 경로
- `"$0"` : 스크립트 경로에 공백이 있기 때문에 따옴표 사용
- `dirname`  : 파일 경로에서 파일 이름 빼고 디렉터리 부분만 출력
- `$(...)`  : 명령어 치환, 괄호 안의 명령어를 실행하고 그 명령의 표준 출력을 이 자리에 넣기
- `exec`  : 현재 bash를 python3로 대체

`exec`가 성공하면 그 아래의 셸 명령은 실행되지 않는다.

```bash
chmod u+x start.sh
./start.sh
```

`start.sh`만 입력하면 PATH에서 찾는다. 현재 디렉터리의 파일은 `./start.sh`로 지정한다. `Permission denied`라면 실행 권한을 확인한다.

## 5. 환경 변수와 인자

```bash
export MODEL="qwen3:0.6b"
# export는 현재 셸에서 실행할 프로그램에 환경 변수를 전달하는 명령
# MODEL : 사용할 AI 모델을 지정하는 변수
# qwen3:0.6b : 사용할 모델 이름
export WEB_PORT="8080"
./start.sh
```

프로그램이 해당 환경 변수를 읽도록 구현되어 있어야 설정이 적용. 별도 스크립트에서 `export`한 값은 자식 프로그램에 전달되지만 원래 부모 터미널의 환경을 바꾸지는 않는다.

- `$1`, `$2` : 첫 번째, 두 번째 인자
- `$#` : 전달받은 인자 수
- `"$@"` : 각 인자의 구분을 유지하여 전체 인자 전달
- `$?` : 직전 명령의 종료 상태. 다른 명령 실행 전에 확인
- `0` : 명령 성공
- `0 이외` : 명령 실패

## 6. 프로그램 확인과 오류 처리

```bash
#!/bin/bash
cd "$(dirname "$0")" || exit 1
if !command -v python3 >/dev/null 2>&1; then
  echo "Python3를 먼저 설치하세요." >&2
  exit 1
fi
exec python3 chat.py
```

- `command -v python3`: 실행 가능한 명령의 위치를 확인, 없는 명령어라면, 아무것도 출력하지 않고 실패 상태 반환한다.
- `!`: 성공/실패 판단을 반대로 바꾼다.
- `if 명령; then ... fi`: 명령 성공 여부로 분기한다.
- if 명령어; then
실행할내용
fi
- 오류 메시지를 출력하는 것과 실패 상태로 종료하는 것은 다르므로 `exit 1`을 따로 쓴다.

리다이렉션은 왼쪽부터 적용. `>/dev/null 2>&1`과 `2>&1 >/dev/null`은 결과가 다름.

- `0`, `1`, `2` : 표준 입력 / 표준 출력 / 표준 오류
- `> 파일` : 표준 출력 덮어쓰기
- `>> 파일` : 표준 출력 추가
- `2> 파일` : 표준 오류 저장
- `>/dev/null` : 표준 출력 버리기
- `2>&1` : 표준 오류를 현재 표준 출력의 목적지로 연결
- `>&2` : 메시지를 표준 오류로 출력

## 7. 여러 줄 파일 작성

```bash
cat > example.sh << 'EOF'
#!/bin/bash
echo "$MODEL"
EOF
```

`<< 'EOF'`는 종료 표시 전까지의 내용을 입력으로 전달한다. 

종료 표시를 따옴표로 감싸면 작성 시점에 `$MODEL`이나 `$(명령)`을 확장하지 않고 문자 그대로 저장한다. 마지막 `EOF`는 단독 줄에 쓴다.
