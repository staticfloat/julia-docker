FROM ppc64le/debian:9

# Eliminate troublesome debian-security repos, as they dropped support for Jessie
RUN sed -i '/debian-security/d' /etc/apt/sources.list

INCLUDE lib/alpha
RUN apt update -y && apt install -y python python-dev curl build-essential
RUN curl -L 'https://bootstrap.pypa.io/get-pip.py' | python

# This enables qemu-*-static emulation on x86_64
ARG QEMU_ARCH=ppc64le
INCLUDE lib/multiarch

INCLUDE lib/omega
