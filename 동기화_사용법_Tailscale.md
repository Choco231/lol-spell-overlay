# Tailscale Sync 사용법

## 지금 한 일

Tailscale은 서로 다른 공유기/인터넷에 있는 PC들을 같은 사설망처럼 묶어줍니다.
이 PC의 Tailscale IP는 `100.78.213.33`입니다.

포트포워딩 없이 접속되는 이유는 공유기를 직접 뚫는 것이 아니라, Tailscale이 PC끼리 연결 경로를 만들어주기 때문입니다.

## 서버 여는 사람

1. Tailscale에 로그인되어 있어야 합니다.
2. `서버_실행.cmd` 실행
3. 창에 표시되는 주소를 사람들에게 공유

예:

```text
http://100.78.213.33:17898
```

4. 서버 창은 닫지 않습니다.
5. overlay는 평소처럼 `롤_스펠_오버레이_실행.vbs`로 실행합니다.

## 접속하는 사람

1. Tailscale 설치
2. 서버 여는 사람과 같은 Tailnet에 들어오기
3. `클라이언트_서버주소_설정.cmd` 실행
4. 서버 URL 입력
5. `롤_스펠_오버레이_실행.vbs` 실행

## 전달할 파일

다른 사람에게는 이 폴더를 압축해서 전달하면 됩니다.

제외해도 되는 것:

- `node_modules`
- `.overlay-user-data`
- `overlay-debug.log`
- `overlay-runtime.log`
- `sync-client-config.json`

받은 사람은 처음에 `설치_및_실행.cmd`를 실행하면 Electron 설치까지 처리됩니다.

## 주의

- 같은 Tailscale 네트워크에 없는 사람은 접속할 수 없습니다.
- 서버 여는 사람의 PC가 꺼지면 동기화도 꺼집니다.
- Windows 방화벽이 물어보면 Node.js 네트워크 접근을 허용해야 합니다.
