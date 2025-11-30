#!/bin/sh

# If command starts with an option, prepend minio.
if [ "${1}" != "minio" ]; then
	if [ -n "${1}" ]; then
		set -- minio "$@"
	fi
fi

if [ "$(id -u)" = '0' ]; then
	exec gosu minio $0 "$@"
fi

exec "$@"
