FROM i386/debian:8.9

# This enables putting `linux32` before commands like `./configure` and `make`
ARG L32=linux32

INCLUDE lib/alpha
RUN apt-get update && apt-get install -y python python-dev curl build-essential
RUN curl -L 'https://bootstrap.pypa.io/get-pip.py' | python

INCLUDE lib/omega
