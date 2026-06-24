# AWS Lightsail Seoul VPS 설정

이 문서는 `lol-spell-overlay` 동기화 서버를 AWS Lightsail Seoul VPS에 24시간 실행하는 방법입니다.

## 1. Lightsail 서버 만들기

AWS Lightsail에서 아래 값으로 인스턴스를 만듭니다.

- Region: `Asia Pacific (Seoul)`
- Platform: `Linux/Unix`
- Blueprint: `Ubuntu 24.04 LTS`
- Plan: `1 GB RAM` 이상

서버 생성 후 Lightsail 방화벽에서 아래 포트를 엽니다.

```text
TCP 22     SSH 접속용
TCP 17898  lol-spell-overlay 동기화 서버
```

`99_posung-lol-matchmaker` 사이트도 같은 VPS에 올릴 예정이면 나중에 사이트용 포트도 추가로 열면 됩니다.

```text
TCP 80     HTTP
TCP 443    HTTPS
TCP 3000   프론트엔드 개발 서버를 직접 열 때만 사용
TCP 8000   백엔드 API를 직접 열 때만 사용
```

운영 형태로는 `80/443`만 열고 Nginx/Caddy가 내부 포트로 넘기게 만드는 구성이 가장 깔끔합니다.

## 2. 서버에 코드 올리기

Lightsail SSH 터미널에서 실행합니다.

```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/Choco231/lol-spell-overlay.git
cd lol-spell-overlay
sudo bash deploy/install-lightsail-sync.sh
```

설치가 끝나면 아래 health check가 성공해야 합니다.

```bash
curl http://127.0.0.1:17898/health
```

정상이면 이런 식으로 나옵니다.

```json
{"ok":true,"port":17898,"rooms":1}
```

## 3. 서비스 확인

서버 상태 확인:

```bash
sudo systemctl status lol-spell-sync
```

로그 확인:

```bash
sudo journalctl -u lol-spell-sync -f
```

재시작:

```bash
sudo systemctl restart lol-spell-sync
```

## 3-1. GitHub 최신 버전으로 재설치

기존 서버 파일을 지우고 GitHub 최신 버전으로 다시 설치하려면 Lightsail SSH에서 실행합니다.

```bash
sudo systemctl stop lol-spell-sync || true
cd ~
rm -rf lol-spell-overlay
sudo rm -rf /opt/lol-spell-overlay
git clone https://github.com/Choco231/lol-spell-overlay.git
cd lol-spell-overlay
sudo bash deploy/install-lightsail-sync.sh
```

설치 후 외부 PC에서 아래 주소가 열리면 정상입니다.

```text
http://52.78.57.73:17898/health
```

## 4. 클라이언트에서 접속

각 사용자 PC에서는 기존 파일을 실행합니다.

```text
클라이언트_실행.cmd
```

서버 주소에는 Lightsail 공인 IP를 넣습니다. 이 저장소의 기본값은 아래 서버로 잡혀 있습니다.

```text
http://52.78.57.73:17898
```

서로 다른 팀이 따로 스펠 체크를 쓰려면 방 코드를 다르게 입력합니다.

```text
팀 A: team1
팀 B: team2
```

같은 방 코드를 입력한 사람끼리만 상태가 동기화됩니다. 방 코드는 영문, 숫자, `-`, `_` 사용을 권장합니다.

## 5. 0.3초 이하 동기화 기준

10명 정도가 쓰는 스펠 동기화는 트래픽이 매우 작습니다. 같은 한국 사용자 기준으로는 서울 리전 VPS의 왕복 지연이 훨씬 중요합니다.

권장 구성:

- AWS Lightsail Seoul
- Ubuntu 24.04 LTS
- 1 GB RAM 이상
- 동기화 서버 포트 `17898`
- 나중에 사이트까지 붙이면 `80/443` + 리버스 프록시

현재 동기화 서버는 HTTP + SSE 방식입니다. 10명 규모에서는 충분히 가볍지만, 더 빠르고 안정적인 실시간 연결이 필요하면 WebSocket 방식으로 바꾸는 것이 다음 단계입니다.
