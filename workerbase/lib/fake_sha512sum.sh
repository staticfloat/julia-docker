#!/bin/sh

if [ "$1" = "--check" ]; then
    shift
    exec /bin/busybox sha512sum -c "$@"
fi
exec /bin/busybox sha512sum "$@"
