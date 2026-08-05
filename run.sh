#!/usr/bin/env bash
set -e

# Load options from Supervisor
PORT="${PORT:-5000}"
HOST="${HOST:-0.0.0.0}"
WORKERS="${WORKERS:-4}"
BACKEND_STORE_URI="${BACKEND_STORE_URI:-sqlite:///mlflow/mlflow.db}"
DEFAULT_ARTIFACT_ROOT="${DEFAULT_ARTIFACT_ROOT:-/mlflow/artifacts}"
STORAGE_PATH="${STORAGE_PATH:-/mlflow}"

# Ensure directories exist
mkdir -p "${STORAGE_PATH}/artifacts" "${STORAGE_PATH}/data"

# Start MLflow tracking server
exec mlflow server \
    --host "${HOST}" \
    --port "${PORT}" \
    --backend-store-uri "${BACKEND_STORE_URI}" \
    --default-artifact-root "${DEFAULT_ARTIFACT_ROOT}" \
    --workers "${WORKERS}"
