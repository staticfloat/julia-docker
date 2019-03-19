FROM arm32v7/debian:8

# Eliminate troublesome debian-security repos, as they dropped support for Jessie
#RUN sed -i '/debian-security/d' /etc/apt/sources.list

# This enables putting `linux32` before commands like `./configure` and `make`
ARG L32=linux32

INCLUDE lib/alpha
RUN apt-get update && apt-get install -y python python-dev curl build-essential
RUN curl -L 'https://bootstrap.pypa.io/get-pip.py' | python

# This enables qemu-*-static emulation on x86_64
ARG QEMU_ARCH=arm
INCLUDE lib/multiarch

INCLUDE lib/omega
