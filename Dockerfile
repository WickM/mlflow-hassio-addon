# check=skip=SecretsUsedInArgOrEnv

# Pin to a specific tag, NOT `:latest`. v3.15.2 is the latest stable patch
# before 3.16.0 introduced the `basic-auth: fail-closed by default` breaking
# change (PR mlflow/mlflow#25308) — we'll evaluate the 3.16 upgrade separately.
# See CHANGELOG.md for the rationale behind this pin.
FROM ghcr.io/mlflow/mlflow:v3.15.2

ENV \
    LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_CMD_WAIT_FOR_SERVICES=1 \
    S6_VERBOSITY=0 \
    SERVICE_PORT=5000 \
    MLFLOW_PORT=5000 \
    # MLflow 3.x FastAPI security middleware (Host header + CORS) reads these
    # env vars. CLI flags `--allowed-hosts` / `--cors-allowed-origins` only
    # affect the legacy Flask middleware; the FastAPI app ignores them.
    # Default "*" so HA ingress (which rewrites the Host header) can reach
    # the UI. Users can lock down via add-on options. See:
    # https://github.com/mlflow/mlflow/blob/master/mlflow/server/security_utils.py
    MLFLOW_SERVER_ALLOWED_HOSTS="*" \
    MLFLOW_SERVER_CORS_ALLOWED_ORIGINS="*"

# Shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Addon base configuration
ARG BUILD_ARCH=amd64
# renovate: datasource=github-releases packageName=hassio-addons/bashio
ARG BASHIO_VERSION="v0.18.1"
# renovate: datasource=github-releases packageName=just-containers/s6-overlay versioning=regex:^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)\.(?<other>\d+)$
ARG S6_OVERLAY_VERSION="3.2.1.0"
# renovate: datasource=github-releases packageName=home-assistant/tempio
ARG TEMPIO_VERSION="2024.11.2"
RUN \
    apt-get update && apt-get install -y --no-install-recommends \
        bash \
        curl \
        jq \
        tzdata \
        tar \
        xz-utils \
    \
    && S6_ARCH="${BUILD_ARCH}" \
    && if [ "${BUILD_ARCH}" = "amd64" ]; then S6_ARCH="x86_64"; fi \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
        | tar -C / -Jxpf - \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" \
        | tar -C / -Jxpf - \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz" \
        | tar -C / -Jxpf - \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz" \
        | tar -C / -Jxpf - \
    \
    && curl -J -L -o /tmp/bashio.tar.gz \
        "https://github.com/hassio-addons/bashio/archive/${BASHIO_VERSION}.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf \
        /tmp/bashio.tar.gz \
        --strip 1 -C /tmp/bashio \
    \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    \
    && curl -L -s -o /usr/bin/tempio \
        "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}" \
    && chmod a+x /usr/bin/tempio \
    \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/*

COPY rootfs /

ENTRYPOINT ["/init"]
CMD []

ARG BUILD_VERSION \
    BUILD_DATE \
    BUILD_DESCRIPTION \
    BUILD_NAME \
    BUILD_REF \
    BUILD_REPOSITORY

LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="Manuel <https://github.com/WickM>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="MLflow Hass.io Add-on" \
    org.opencontainers.image.authors="Manuel <https://github.com/WickM>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/WickM" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.version="${BUILD_VERSION}"
