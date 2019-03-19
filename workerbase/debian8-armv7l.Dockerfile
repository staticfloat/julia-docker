FROM arm32v7/debian:8

# This enables putting `linux32` before commands like `./configure` and `make`
ARG L32=linux32

# We need to manually override binutils/gcc's host triplets
ARG TRIPLET="arm-linux-gnueabihf"
ARG binutils_configure_flags="--host=${TRIPLET} --build=${TRIPLET} --target=${TRIPLET} --enable-lto --enable-plugins"
ARG gcc_configure_flags="--host=${TRIPLET} --build=${TRIPLET} --target=${TRIPLET} --with-arch=armv7-a --with-float=hard --with-fpu=vfpv3-d16 --enable-lto --enable-plugin"

INCLUDE lib/alpha
INCLUDE lib/builddeps_apt
INCLUDE lib/build_tools

# This enables qemu-*-static emulation on x86_64
ARG qemu_arch=arm
INCLUDE lib/multiarch

INCLUDE lib/omega

