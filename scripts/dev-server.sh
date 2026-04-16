#!/usr/bin/env bash
# Start a local PowerMem server for SDK testing.
#
# Usage:
#   scripts/dev-server.sh            # foreground
#   scripts/dev-server.sh --bg       # background (logs to .pmem-server.log)
#   scripts/dev-server.sh --stop     # kill backgrounded server

set -euo pipefail
cd "$(dirname "$0")/.."

VENV="./.venv"
ENV_FILE="${POWERMEM_ENV_FILE:-.env}"
HOST="${POWERMEM_SERVER_HOST:-127.0.0.1}"
PORT="${POWERMEM_SERVER_PORT:-8000}"
LOG_FILE=".pmem-server.log"
PID_FILE=".pmem-server.pid"

if [[ ! -x "$VENV/bin/powermem-server" ]]; then
  echo "error: $VENV/bin/powermem-server not found. Run: python3 -m venv .venv && .venv/bin/pip install powermem" >&2
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "error: $ENV_FILE not found. Copy .env.example to .env and fill it in." >&2
  exit 1
fi

case "${1:-}" in
  --stop)
    if [[ -f "$PID_FILE" ]]; then
      pid="$(cat "$PID_FILE")"
      kill "$pid" 2>/dev/null && echo "stopped $pid" || echo "no running server at $pid"
      rm -f "$PID_FILE"
    else
      pkill -f "powermem-server --host $HOST --port $PORT" 2>/dev/null && echo "stopped" || echo "no running server"
    fi
    ;;
  --bg)
    set -a; source "$ENV_FILE"; set +a
    nohup "$VENV/bin/powermem-server" --host "$HOST" --port "$PORT" > "$LOG_FILE" 2>&1 &
    echo "$!" > "$PID_FILE"
    echo "started PID $(cat "$PID_FILE"), logs at $LOG_FILE"
    echo "boot takes ~30s; tail the log until you see 'Application startup complete.'"
    ;;
  ""|--fg)
    set -a; source "$ENV_FILE"; set +a
    exec "$VENV/bin/powermem-server" --host "$HOST" --port "$PORT"
    ;;
  *)
    echo "usage: $0 [--fg|--bg|--stop]" >&2
    exit 2
    ;;
esac
