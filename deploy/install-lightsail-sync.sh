#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/lol-spell-overlay"
SERVICE_NAME="lol-spell-sync"
PORT="${LOL_SPELL_SYNC_PORT:-17898}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo bash deploy/install-lightsail-sync.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

apt-get update
apt-get install -y nodejs npm curl rsync ufw

if ! id -u lolspell >/dev/null 2>&1; then
  useradd --system --home "${APP_DIR}" --shell /usr/sbin/nologin lolspell
fi

mkdir -p "${APP_DIR}"
rsync -a --delete \
  --exclude ".git" \
  --exclude "node_modules" \
  --exclude ".overlay-user-data" \
  --exclude "*.log" \
  --exclude "sync-client-config.json" \
  "${REPO_DIR}/" "${APP_DIR}/"

chown -R lolspell:lolspell "${APP_DIR}"

install -m 0644 "${REPO_DIR}/deploy/lol-spell-sync.service" "/etc/systemd/system/${SERVICE_NAME}.service"

ufw allow OpenSSH >/dev/null || true
ufw allow "${PORT}/tcp" >/dev/null || true

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}"
systemctl restart "${SERVICE_NAME}"

echo ""
echo "LoL Spell Sync Server installed."
echo "Service: ${SERVICE_NAME}"
echo "Port: ${PORT}"
echo ""
systemctl --no-pager --full status "${SERVICE_NAME}" || true
echo ""
echo "Health check:"
curl -fsS "http://127.0.0.1:${PORT}/health" && echo ""
