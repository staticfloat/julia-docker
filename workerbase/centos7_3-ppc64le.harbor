FROM ibmcom/centos-ppc64le:7




INCLUDE lib/alpha
INCLUDE lib/builddeps_yum
INCLUDE lib/build_tools

# This enables qemu-*-static emulation on x86_64
ARG QEMU_ARCH=ppc64le
INCLUDE lib/multiarch

INCLUDE lib/omega
