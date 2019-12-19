FROM alpine:3.8





INCLUDE lib/alpha
RUN apk add gcc g++ make libressl-dev zlib-dev bzip2-dev curl tar xz libffi-dev
INCLUDE lib/python_install
INCLUDE lib/omega

