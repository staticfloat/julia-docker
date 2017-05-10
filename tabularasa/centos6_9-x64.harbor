FROM centos:6.9




INCLUDE lib/alpha
RUN yum update -y && yum install -y gcc gcc-c++ make openssl-devel zlib-devel bzip2-devel curl tar xz
INCLUDE lib/python_install


INCLUDE lib/omega
