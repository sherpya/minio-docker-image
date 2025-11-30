# MinIO Docker Image

A custom Docker image for [MinIO](https://min.io/) - High Performance Object Storage, API compatible with Amazon S3 cloud storage service.

## Features

- Based on `debian:trixie-slim` for a minimal footprint
- Multi-architecture support (amd64, arm64)
- Includes MinIO server and `mc` (MinIO Client)
- Uses [gosu](https://github.com/tianon/gosu) for secure privilege de-escalation
- Runs as non-root `minio` user

## Quick Start

```sh
docker run -p 9000:9000 -v /path/to/data:/data ghcr.io/sherpya/minio-docker-image:latest server /data
```

## Environment Variables

Configure MinIO using standard environment variables:

- `MINIO_ROOT_USER` - Root user/access key
- `MINIO_ROOT_PASSWORD` - Root password/secret key

## Building Locally

```sh
docker build -t minio-custom .
```

## CI/CD

This project includes CI/CD configurations for:

- **GitHub Actions**: [.github/workflows/docker-image.yml](.github/workflows/docker-image.yml) - Builds and pushes to GitHub Container Registry
- **GitLab CI**: [.gitlab-ci.yml](.gitlab-ci.yml) - Multi-arch build for amd64 and arm64

## Exposed Ports

- `9000` - MinIO API and Console

## Volumes

- `/data` - MinIO data directory

## License

MinIO is released under the [GNU AGPLv3 license](https://github.com/minio/minio/blob/master/LICENSE).
