#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8000}"
HOST="${HOST:-0.0.0.0}"
RELOAD="${RELOAD:-true}"

cd "$(dirname "$0")"

if [[ -d "venv" ]]; then
  VENV_DIR="venv"
elif [[ -d ".venv" ]]; then
  VENV_DIR=".venv"
else
  echo "Virtual environment not found."
  echo "Create one with: python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt"
  exit 1
fi

source "$VENV_DIR/bin/activate"

python - <<'PY'
import importlib.util
import sys

required = {
    "fastapi": "fastapi",
    "fitz": "pymupdf",
    "uvicorn": "uvicorn",
}

missing = [package for module, package in required.items() if importlib.util.find_spec(module) is None]

if missing:
    print("Missing backend dependencies:", ", ".join(missing))
    print("Install them with: pip install -r requirements.txt")
    sys.exit(1)
PY

if command -v lsof >/dev/null 2>&1; then
  PORT_OWNER="$(lsof -tiTCP:"$PORT" -sTCP:LISTEN | xargs || true)"
  if [[ -n "$PORT_OWNER" ]]; then
    echo "Backend port $PORT is already in use."
    echo "If this is your existing backend, keep using it: http://127.0.0.1:$PORT/"
    echo "To use another port, run: PORT=8001 ./run.sh"
    echo "To stop the existing process, run: kill $PORT_OWNER"
    exit 0
  fi
fi

echo "Starting backend on http://127.0.0.1:$PORT ..."

UVICORN_ARGS=(main:app --host "$HOST" --port "$PORT")

if [[ "$RELOAD" == "true" ]]; then
  UVICORN_ARGS+=(--reload)
fi

exec python -m uvicorn "${UVICORN_ARGS[@]}"
