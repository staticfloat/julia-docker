#!/bin/bash

# Auto-calculate stored name unless its given
URL="$1"
if [[ -z "$2" ]]; then
    TARBALL="/downloads/$(basename "$1")"
else
    TARBALL="$2"
fi

# Download the file if it does not already exist
if [[ ! -f ${TARBALL} ]]; then
    curl -q -# -L ${EXTRA_CURL_FLAGS} "${URL}" -o "${TARBALL}"
fi

# Extract it into the current directory
if [[ "${TARBALL}" == *.tar.gz ]] || [[ "${TARBALL}" == *.tgz ]]; then
    tar zxf "${TARBALL}"
elif [[ "${TARBALL}" == *.tar.bz2 ]]; then
    tar jxf "${TARBALL}"
elif [[ "${TARBALL}" == *.tar.xz ]] || [[ "${TARBALL}" == *.txz ]]; then
    tar Jxf "${TARBALL}"
else
    echo "Unknown tarball type ${TARBALL#*.}" >&2
fi

# Tar sometimes keeps around user IDs and stuff that I don't like, fix that:
chown $(id -u):$(id -g) -R .
