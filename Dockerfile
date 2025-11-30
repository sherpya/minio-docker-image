FROM debian:trixie-slim

ARG TARGETARCH
ARG RELEASE=RELEASE.2025-09-07T16-13-09Z

LABEL org.opencontainers.image.authors="sherpya@gmail.com"
LABEL org.opencontainers.image.title="MinIO Docker Image"
LABEL org.opencontainers.image.description="MinIO is a High Performance Object Storage, API compatible with Amazon S3 cloud storage service"

SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

# Upgrade packages & Dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gnupg procps netcat-traditional iputils-ping htop \
    curl ca-certificates \
    && apt-get clean && rm -fr /var/lib/apt/lists/* /var/log/dpkg.log \
    /var/log/alternatives.log /var/log/apt \
    /var/cache/debconf/*-old /var/lib/dpkg/available-old

# Download minio binary and signature
RUN curl -s -q https://dl.min.io/server/minio/release/linux-${TARGETARCH}/archive/minio.${RELEASE} -o /usr/bin/minio && \
    curl -s -q https://dl.min.io/server/minio/release/linux-${TARGETARCH}/archive/minio.${RELEASE}.sha256sum -o /usr/bin/minio.sha256sum && \
    echo $(cut -f1 -d' ' /usr/bin/minio.sha256sum) /usr/bin/minio | sha256sum -c && \
    rm -f /usr/bin/minio.sha256sum && \
    chmod +x /usr/bin/minio

# Download mc binary and signature
RUN curl -s -q https://dl.min.io/client/mc/release/linux-${TARGETARCH}/mc -o /usr/bin/mc && \
    curl -s -q https://dl.min.io/client/mc/release/linux-${TARGETARCH}/mc.sha256sum -o /usr/bin/mc.sha256sum && \
    echo $(cut -f1 -d' ' /usr/bin/mc.sha256sum) /usr/bin/mc | sha256sum -c - && \
    rm -f /usr/bin/mc.sha256sum && \
    chmod +x /usr/bin/mc

# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ARG GOSU_VERSION=1.19
RUN set -eux; \
    curl -s -q -L -o /usr/local/bin/gosu https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}; \
    curl -s -q -L -o /usr/local/bin/gosu.asc https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}.asc; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN useradd -ms /bin/bash minio
RUN install --verbose --directory --owner minio --group minio --mode 700 /data
VOLUME /data

EXPOSE 9000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["minio"]
