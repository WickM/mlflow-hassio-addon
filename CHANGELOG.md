# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-09-04

### Changed

- **Pin MLflow base image** from `ghcr.io/mlflow/mlflow:latest` to a specific
  tag (`v3.15.2`). Previously `:latest` could silently swap versions on every
  image rebuild; pinning guarantees reproducible deploys. `v3.15.2` is the
  most recent stable patch *before* MLflow 3.16.0, which introduced a
  breaking auth change (`basic-auth: enable fail-closed authorization by
  default`, PR #25308) — we'll evaluate that separately.

## [1.0.0] - 2026-08-06

### Added

- Initial release of the MLflow hassio add-on.
- MLflow 3.x FastAPI security middleware (`MLFLOW_SERVER_ALLOWED_HOSTS` /
  `MLFLOW_SERVER_CORS_ALLOWED_ORIGINS`) wired through the add-on options.
- `init: false` + s6-overlay stock `/init` (avoids the s6-overlay-suexec
  PID 1 conflict when wrapping upstream Docker images under HA Supervisor).
- amd64 + aarch64 multi-arch images, then amd64-only after QEMU segfault
  on cross-builds.
- GitHub Actions build pipeline (`ghcr.io/wickm/mlflow-hassio-addon`).

[1.0.1]: https://github.com/WickM/mlflow-hassio-addon/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/WickM/mlflow-hassio-addon/releases/tag/v1.0.0
