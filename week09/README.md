# 9주차 - 쿠버네티스 첫 배포

## 1. 클러스터 만들기 (kubectl get nodes)

사용한 도구: **minikube** (kubectl + minikube, 드라이버는 docker)

```bash
$ kubectl version --client
$ minikube start --driver=docker
$ minikube status
$ kubectl get nodes
```

```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   1m    v1.3x.x
```

![kubectl get nodes](images/get-nodes.png)

- kubectl은 클러스터에 명령을 보내는 리모컨이고, minikube는 노트북 안에 노드 1개짜리 클러스터를 만들어 주는 TV 역할이다.
- 도커 데스크톱이 켜져 있어야 minikube가 동작한다. (minikube 컨테이너 하나가 곧 노드)

## 2. 자가 치유 (Pod를 지운 뒤 새 Pod가 생기는 것 확인)

`kubectl run`으로 만든 Pod는 지우면 다시 생기지 않았다. Deployment로 3개를 선언하니까 지워도 다시 생겼다.

```bash
# 터미널 1
$ kubectl create deployment mynginx --image=nginx --replicas=3
$ kubectl get pods
$ kubectl delete pod mynginx-xxxxxxxxxx-xxxxx

# 터미널 2
$ kubectl get pods -w
```

![get pods -w](images/self-healing.png)

- 지운 Pod는 `Terminating`이 되고, 이름 끝이 다른 새 Pod가 `Pending` → `Running`으로 바로 생겼다.
- "살려라"라는 명령은 안 했고 "3개가 있어야 한다"고 선언만 했는데, 쿠버네티스가 2개인 걸 보고 1개를 더 만든 것이다.
- 되살린 게 아니라 새로 만든 것이라서 Pod 안에 임시로 저장한 데이터는 사라진다.

## 3. 내 방명록을 쿠버네티스에서 띄우기

6주차에 push한 내 이미지를 Deployment로 띄웠다.

```bash
$ kubectl delete deployment mynginx
$ kubectl create deployment guestbook --image=ghcr.io/내아이디/guestbook:v1
$ kubectl get pods -w
$ kubectl get deployments
$ kubectl logs -l app=guestbook
$ kubectl port-forward deployment/guestbook 8080:5000
```

브라우저에서 `http://localhost:8080` 접속

![방명록 화면](images/guestbook-k8s.png)

- 제목: InhaTC DevOps 방명록
- Pod/Host: `guestbook-xxxxxxxxx-xxxxx` (화면 배지에 나온 Pod 이름)
- 저장소: Memory
- `8080:5000`은 내 컴퓨터 8080 → 컨테이너 5000으로 연결한다는 뜻이다.
- Pod를 지우면 새 Pod는 다시 생기지만, port-forward 연결은 끊겨서 다시 실행해야 했다.

## 4. 선언형이란 (내 말로)

"어떻게 하라"고 하나하나 시키는 게 아니라 "이런 상태여야 한다"고 정해 두면 알아서 맞춰 주는 방식이다. 예를 들면 에어컨을 26도로 맞춰 두면 알아서 켜지고 꺼지는 것과 같다.

## 5. 막혔던 것과 해결 방법

| 막힌 것 | 해결 방법 |
|---|---|
| (예: ImagePullBackOff) | (예: GHCR 패키지를 Public으로 바꾸고 `kubectl delete pod -l app=guestbook`) |

## 마무리

```bash
$ kubectl delete deployment guestbook
$ minikube stop
```
