FROM staticfloat/centos-i386:centos6

# This enables putting `linux32` before commands like `./configure` and `make`
ARG L32=linux32

INCLUDE lib/alpha
RUN yum update -y && yum install -y gcc gcc-c++ make openssl-devel zlib-devel bzip2-devel curl tar xz
INCLUDE lib/python_install


INCLUDE lib/omega
