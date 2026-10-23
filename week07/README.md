# 7주차 - Docker Compose

> Windows + WSL2 Ubuntu 기준 정리임. 코드 예시는 참고용이며 실제 실행 결과는 직접 기록해야 함.
> 출처: `DevOps_07_도커_컴포즈 (1).pdf` (1~62쪽).

## Compose

여러 컨테이너의 설정을 compose.yaml에 적고 함께 실행·관리하는 도구임. 여러 컨테이너를 하나로 합치는 것은 아님.

```text
브라우저 → nginx → web 여러 개 → Redis
```

앱과 DB를 나누면 각각 수정하거나 늘리기 쉬움. Redis는 메모리 기반 저장소이며 디스크 저장도 설정 가능함.

## YAML 기본

- 같은 단계는 들여쓰기를 맞춰야 함
- 들여쓰기에는 Tab 대신 스페이스 사용함
- `이름: 값` : 항목과 값
- `- 값` : 목록
- `nano -ET2 compose.yaml` : Tab 입력을 공백으로 바꿔서 편집 가능함

## 주요 설정

- `services` : 실행할 서비스들
- `build` : Dockerfile 빌드 위치
- `image` : 사용할 이미지
- `command` : 기본 실행 명령 변경
- `ports` : 호스트와 컨테이너 포트 연결
- `expose` : 내부 사용 포트 표시. 호스트에 공개하지 않음
- `environment` : 환경 변수 전달
- `volumes` : 데이터 저장 공간이나 파일 연결
- `depends_on` : 시작 순서와 의존성
- `healthcheck` : 정상 상태 점검
- `restart` : 재시작 정책
- `develop.watch` : 개발 중 파일 변경 감시

## 기본 예시

LMS의 guestbook 앱과 Dockerfile이 준비되어 있어야 함. 비밀번호는 같은 폴더의 .env에 직접 작성함.

```dotenv
REDIS_PASSWORD=직접_정한_실습용_값
```

```yaml
services:
  web:
    build: .
    ports:
      - "8080:5000"
    environment:
      APP_TITLE: "방명록"
      REDIS_HOST: "redis"
      REDIS_PORT: "6379"
      REDIS_PASSWORD: "${REDIS_PASSWORD:?비밀번호 설정 필요}"
    depends_on:
      - redis
    restart: unless-stopped
  redis:
    image: redis:7-alpine
    command: ["redis-server", "--requirepass", "${REDIS_PASSWORD:?비밀번호 설정 필요}", "--appendonly", "yes"]
    volumes:
      - redis-data:/data
volumes:
  redis-data:
```

이 예시의 depends_on은 먼저 시작하게 할 뿐 준비 완료까지 기다리지는 않음.

## 명령어

```bash
cd ~/devops/guestbook
docker compose config -q
docker compose up -d
docker compose ps
docker compose logs -f web
```

- `config -q` : 설정 검사. 실제 앱 정상 작동까지 확인해 주지는 않음
- `up -d` : 백그라운드 실행
- `up -d --build` : 빌드 후 실행
- `ps` : 상태 확인
- `logs -f web` : web 로그 계속 확인. Ctrl+C는 로그 보기만 종료
- `exec web sh` : web 안에서 셸 실행
- `restart web` : web 재시작
- `down` : 컨테이너와 기본 네트워크 등 정리. 명명된 볼륨은 기본 유지
- `down -v` : 볼륨도 삭제함. 데이터가 사라질 수 있어 주의해야 함

## 컨테이너끼리 연결

같은 네트워크에서는 서비스 이름으로 연결 가능함. web에서 Redis는 localhost가 아니라 redis로 접근해야 함. 컨테이너의 localhost는 자기 자신임.

```bash
docker compose exec web python -c "import socket; print(socket.gethostbyname('redis'))"
```

Redis에 ports를 안 쓰면 호스트 localhost:6379로 포트를 공개하지 않음. 내부 컨테이너끼리는 통신 가능함. expose가 있어야만 통신되는 것은 아님.

## 데이터와 볼륨

- web 메모리에 저장 : web 재시작 시 사라짐
- Redis에 저장 : web만 재시작하면 유지됨
- Redis AOF와 볼륨 사용 : 컨테이너를 다시 만들어도 저장 파일로 복구 가능함
- `--appendonly yes` : Redis AOF 저장 사용
- `redis-data:/data` : Redis 데이터 폴더를 볼륨에 연결
- `docker volume ls` : 볼륨 목록 확인

down 후 up은 볼륨을 재사용하고 down -v 후 up은 삭제된 데이터가 돌아오지 않음. 볼륨 자체 삭제나 디스크 고장에 대비하려면 백업도 필요함.

## .env

- .env : 내 PC에서 사용할 설정값
- .env.example : 실제 비밀값 없이 작성 방법만 공유하는 파일
- .gitignore : .env가 Git에 새로 추가되지 않도록 설정
- .dockerignore : .env가 이미지 안에 복사되지 않도록 설정
- `${REDIS_PASSWORD:?메시지}` : 값이 없거나 비어 있으면 오류 발생

.env는 암호화가 아님. 이미 올린 비밀번호는 파일에서 지워도 Git 기록에 남을 수 있음. .env 값이 전부 자동 전달되는 것도 아니며 environment 등에서 사용해야 함. config 출력에는 비밀번호가 보일 수 있어 캡처 주의해야 함.

## healthcheck

실행 중인 것과 정상 요청을 받을 준비가 된 것은 다름. healthcheck로 준비 상태를 확인함.

Redis 서비스에 추가할 예시임.

```yaml
healthcheck:
  test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
  interval: 5s
  timeout: 3s
  retries: 5
```

web 서비스의 depends_on을 바꾸고 상태 점검을 추가하는 예시임.

```yaml
depends_on:
  redis:
    condition: service_healthy
healthcheck:
  test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:5000/readyz')"]
  interval: 5s
  timeout: 3s
  retries: 5
```

- test : 컨테이너 안에서 실행할 점검 명령. 종료 코드 0이면 성공임
- interval : 점검 주기
- timeout : 제한 시간
- retries : 연속 실패 횟수
- service_healthy : 의존 서비스가 정상일 때 시작
- starting / healthy / unhealthy : 점검 중 / 정상 / 비정상

/readyz는 교안 앱에 있는 경로임. healthcheck가 실패했다고 일반 Compose에서 자동으로 재시작되는 것은 아님.

## web 여러 개 실행

```bash
docker compose up -d --scale web=3
```

web 3개를 실행하라는 뜻임. 모두 호스트 8080을 쓰게 하면 충돌하므로 web의 ports를 제거하고 nginx가 외부 요청을 받게 함. web에는 expose로 5000을 표시할 수 있음. 고정 container_name도 여러 개 실행할 때 문제가 됨.

- scale-out / scale-in : 개수 늘림 / 줄임
- scale-up / scale-down : 개별 서버 자원 늘림 / 줄임
- 리버스 프록시 : 요청을 대신 받아 내부 서버에 전달
- 로드 밸런싱 : 여러 서버로 요청을 나눔

nginx.conf 예시임.

```nginx
server {
    listen 80;
    resolver 127.0.0.11 valid=5s;
    location / {
        set $backend http://web:5000;
        proxy_pass $backend;
    }
}
```

127.0.0.11은 Docker 내부 DNS임. valid=5s는 DNS 결과를 캐시에 두는 시간임. 변수를 사용하여 이름을 다시 조회할 수 있게 함. 여러 web으로 요청이 갈 수 있지만 항상 정확히 순서대로 나뉜다는 뜻은 아님.

services 아래에 추가할 nginx 설정 조각임. web의 ports를 제거하고 앞의 web healthcheck도 적용해야 함. nginx를 web·redis와 같은 단계로 들여써야 함.

```yaml
nginx:
  image: nginx:alpine
  ports:
    - "8080:80"
  volumes:
    - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
  depends_on:
    web:
      condition: service_healthy
```

ro는 읽기 전용임. 새로고침 시 Host가 바뀌면 서로 다른 web이 응답한 것임. 데이터는 공통 Redis를 사용하므로 같게 보임.

## 48쪽 문제 관련 개념

- unless-stopped는 사람이 stop한 컨테이너를 자동으로 다시 켜지 않음
- --scale web=3은 명령 실행 시 개수를 맞춤. 계속 감시해서 항상 유지하는 기능은 아님
- healthcheck는 상태 확인이며 개수 유지 기능과 다름
- 남은 web이 응답할 수 있지만 일시적으로 오류가 날 수도 있음
- PC나 서버 자체가 꺼지면 같은 PC의 재시작 정책만으로 해결 안 됨

과제 해결 코드와 장단점은 직접 작성·실험한 뒤 정리할 예정임.

## watch

web 서비스 아래에 넣는 설정임.

```yaml
develop:
  watch:
    - action: rebuild
      path: ./app.py
    - action: rebuild
      path: ./templates
```

```bash
docker compose up --watch
# 또는 실행과 감시를 다른 터미널로 나눔
docker compose up -d --scale web=3
docker compose watch --no-up
```

rebuild는 파일 변경 시 이미지를 다시 빌드하고 컨테이너를 다시 만듦. up --watch에서 Ctrl+C는 서비스 중지, watch --no-up에서는 감시만 종료함. 설치 버전이 기능을 지원하는지 확인해야 함.

## 실습 후 기록

- 실행한 명령과 만든 파일 : 실습 후 작성 예정임
- 실제 결과와 캡처 : 실습 후 추가 예정임
- 오류와 해결 방법 : 실습 후 작성 예정임
- 새로 이해한 점 : 내 말로 추가할 예정임
