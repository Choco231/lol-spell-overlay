# Tailscale 동기화 사용법

사용자가 알면 되는 파일은 3개입니다.

```text
1. 설치_및_실행.cmd
2. 서버_실행.cmd
3. 클라이언트_실행.cmd
```

영문 파일명이 필요한 PC에서는 같은 기능의 아래 파일을 쓰면 됩니다.

```text
1. install_run.cmd
2. server_run.cmd
3. client_run.cmd
```

## 1. 처음 설치

모든 사람이 먼저 실행합니다.

```text
설치_및_실행.cmd
```

이 파일이 처리하는 것:

- Node.js 설치 확인
- Electron 의존성 설치
- Tailscale 설치 확인
- Tailscale이 로그아웃 상태면 로그인 진행

Tailscale 로그인/가입은 브라우저에서 직접 해야 합니다.

## 2. 서버 여는 사람

한 명만 실행합니다.

```text
서버_실행.cmd
```

실행하면 창에 이런 주소가 표시됩니다.

```text
http://100.x.x.x:17898
```

이 주소를 나머지 사람들에게 공유합니다.

서버 창은 닫으면 안 됩니다. 서버 창이 닫히면 동기화도 꺼집니다.

서버 여는 사람의 overlay도 자동으로 실행됩니다.

## 3. 접속하는 사람

서버가 공유해준 주소를 입력합니다.

```text
클라이언트_실행.cmd
```

예:

```text
http://100.78.213.33:17898
```

주소를 저장한 뒤 overlay가 자동으로 실행됩니다.

## 전달할 때 빼도 되는 것

압축해서 다른 사람에게 보낼 때 아래 항목은 빼도 됩니다.

```text
node_modules
.overlay-user-data
sync-client-config.json
overlay-debug.log
overlay-runtime.log
sync-server-runtime.log
sync-server-runtime.err.log
```

받은 사람은 `설치_및_실행.cmd`부터 실행하면 됩니다.

## 주의

- 같은 Tailscale Tailnet에 들어온 사람끼리만 접속됩니다.
- 공유기 포트포워딩은 필요 없습니다.
- Windows 방화벽이 Node.js 허용을 물어보면 허용해야 합니다.
