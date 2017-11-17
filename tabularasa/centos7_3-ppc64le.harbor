FROM ibmcom/centos-ppc64le:7




INCLUDE lib/alpha
RUN yum update -y && yum install -y python python-devel curl gcc gcc-c++ make
RUN curl -L 'https://bootstrap.pypa.io/get-pip.py' | python

# This enables qemu-*-static emulation on x86_64
ARG QEMU_ARCH=ppc64le
INCLUDE lib/multiarch

INCLUDE lib/omega
