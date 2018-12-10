FROM centos:6.9




INCLUDE lib/alpha
INCLUDE lib/builddeps_yum
INCLUDE lib/build_tools

COPY build_crosscompiler.sh /build.sh
COPY patches /downloads/patches

INCLUDE lib/omega
