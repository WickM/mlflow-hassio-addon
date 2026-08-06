#!/usr/bin/env bash
set -e

# Load options from Supervisor
PORT="${PORT:-5000}"
HOST="${HOST:-0.0.0.0}"
WORKERS="${WORKERS:-4}"
BACKEND_STORE_URI="${BACKEND_STORE_URI:-sqlite:///mlflow/mlflow.db}"
DEFAULT_ARTIFACT_ROOT="${DEFAULT_ARTIFACT_ROOT:-/mlflow/artifacts}"
STORAGE_PATH="${STORAGE_PATH:-/mlflow}"

# MLflow 3.x security middleware (FastAPI app) reads from these env vars,
# not the CLI flags. Defaults to "*" so the Web UI is reachable from HA
# ingress / other containers on the host. Users can lock down via add-on
# Configuration if exposing publicly.
ALLOWED_HOSTS="${allowed_hosts:-${MLFLOW_SERVER_ALLOWED_HOSTS:-*}}"
CORS_ORIGINS="${cors_origins:-${MLFLOW_SERVER_CORS_ALLOWED_ORIGINS:-*}}"
export MLFLOW_SERVER_ALLOWED_HOSTS="${ALLOWED_HOSTS}"
export MLFLOW_SERVER_CORS_ALLOWED_ORIGINS="${CORS_ORIGINS}"

# Diagnostic: log environment + tool locations so failures are debuggable from HA log
echo "[run.sh] uid=$(id -u) cwd=$(pwd) PATH=$PATH"
echo "[run.sh] mlflow binary: $(command -v mlflow || echo 'NOT FOUND on PATH')"
echo "[run.sh] python: $(command -v python || command -v python3 || echo 'NOT FOUND')"
echo "[run.sh] PORT=$PORT HOST=$HOST WORKERS=$WORKERS"
echo "[run.sh] MLFLOW_SERVER_ALLOWED_HOSTS=$MLFLOW_SERVER_ALLOWED_HOSTS"
echo "[run.sh] MLFLOW_SERVER_CORS_ALLOWED_ORIGINS=$MLFLOW_SERVER_CORS_ALLOWED_ORIGINS"

# Ensure storage directories exist (defensive — cont-init should have done this)
mkdir -p "${STORAGE_PATH}/artifacts" "${STORAGE_PATH}/data"

# Resolve mlflow entrypoint. MLflow base image ships the CLI as a Python module;
# prefer an absolute binary if present, fall back to `python -m mlflow`.
MLFLOW_BIN="$(command -v mlflow || true)"
if [ -n "${MLFLOW_BIN}" ] && [ -x "${MLFLOW_BIN}" ]; then
    echo "[run.sh] starting mlflow via ${MLFLOW_BIN}"
    exec "${MLFLOW_BIN}" server \
        --host "${HOST}" \
        --port "${PORT}" \
        --backend-store-uri "${BACKEND_STORE_URI}" \
        --default-artifact-root "${DEFAULT_ARTIFACT_ROOT}" \
        --workers "${WORKERS}" \
        --allowed-hosts "${ALLOWED_HOSTS}" \
        --cors-allowed-origins "${CORS_ORIGINS}"
else
    PY="$(command -v python || command -v python3)"
    echo "[run.sh] starting mlflow via ${PY} -m mlflow"
    exec "${PY}" -m mlflow server \
        --host "${HOST}" \
        --port "${PORT}" \
        --backend-store-uri "${BACKEND_STORE_URI}" \
        --default-artifact-root "${DEFAULT_ARTIFACT_ROOT}" \
        --workers "${WORKERS}" \
        --allowed-hosts "${ALLOWED_HOSTS}" \
        --cors-allowed-origins "${CORS_ORIGINS}"
fi
