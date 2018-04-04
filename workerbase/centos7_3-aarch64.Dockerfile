FROM centos/aarch64




INCLUDE lib/alpha
INCLUDE lib/builddeps_yum
INCLUDE lib/build_tools

# This enables qemu-*-static emulation on x86_64
ARG qemu_arch=aarch64
INCLUDE lib/multiarch


INCLUDE lib/omega
