# Builder stage
FROM golang:latest AS builder

ARG MINIO_VERSION=RELEASE.2025-10-15T17-29-55Z
ARG MC_VERSION=RELEASE.2025-08-13T08-35-41Z
ARG GOSU_VERSION=1.19

# Build MinIO
RUN go install -v -ldflags="-X github.com/minio/minio/cmd.Version=${MINIO_VERSION} -X github.com/minio/minio/cmd.ReleaseTag=${MINIO_VERSION}" github.com/minio/minio@${MINIO_VERSION}

# Build mc
RUN go install -v -ldflags="-X github.com/minio/mc/cmd.Version=${MC_VERSION} -X github.com/minio/mc/cmd.ReleaseTag=${MC_VERSION}" github.com/minio/mc@${MC_VERSION}

# Build gosu
RUN go install -v github.com/tianon/gosu@${GOSU_VERSION}

# Strip binaries to reduce size
RUN strip /go/bin/*

# Final image
FROM debian:trixie-slim

LABEL org.opencontainers.image.authors="sherpya@gmail.com"
LABEL org.opencontainers.image.title="MinIO Docker Image"
LABEL org.opencontainers.image.description="MinIO is a High Performance Object Storage, API compatible with Amazon S3 cloud storage service"
LABEL org.opencontainers.image.source="https://github.com/sherpya/minio-docker-image"

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

# Copy binaries from builder
COPY --from=builder /go/bin/minio /usr/bin/minio
COPY --from=builder /go/bin/mc /usr/bin/mc
COPY --from=builder /go/bin/gosu /usr/bin/gosu

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN useradd -ms /bin/bash minio
RUN install --verbose --directory --owner minio --group minio --mode 700 /data
VOLUME /data

EXPOSE 9000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["minio"]
