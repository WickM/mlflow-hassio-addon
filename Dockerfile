ARG BUILD_FROM
FROM $BUILD_FROM

# Install Python and MLflow dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    py3-wheel \
    && pip3 install --break-system-packages --no-cache-dir \
        mlflow \
        sqlalchemy \
        alembic

# Create MLflow working directory
RUN mkdir -p /mlflow/artifacts /mlflow/data

# Copy rootfs
COPY rootfs /

WORKDIR /mlflow
