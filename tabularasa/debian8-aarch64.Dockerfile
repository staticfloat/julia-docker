FROM arm64v8/debian:8

# Eliminate troublesome debian-security repos, as they dropped support for Jessie
RUN sed -i '/debian-security/d' /etc/apt/sources.list

INCLUDE lib/alpha
RUN apt update -y && apt install -y python python-dev curl build-essential
RUN curl -L 'https://bootstrap.pypa.io/get-pip.py' | python

# This enables qemu-*-static emulation on x86_64
ARG QEMU_ARCH=aarch64
INCLUDE lib/multiarch

INCLUDE lib/omega
