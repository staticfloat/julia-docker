FROM ubuntu:16.04




INCLUDE lib/alpha
RUN apt update && apt install -y python python-dev curl build-essential unzip
RUN curl -L 'https://bootstrap.pypa.io/get-pip.py' | python
INCLUDE lib/omega
