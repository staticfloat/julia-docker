# Build an image that contains all of our cross compilers and all that stuff.
FROM alpine:3.6

# These are where we'll do all our work, so make them now
RUN mkdir -p /src /downloads

# We use the "download_unpack.sh" command a lot, throw it into /usr/bin
COPY download_unpack.sh /usr/bin

# We use a `tar` wrapper to insert extra command line flags on every tar command
COPY tar_wrapper.sh /usr/local/bin/tar
RUN chmod +x /usr/local/bin/tar

# Install build tools (BUILD_TOOLS are things needed during the build, but not at runtime)
ARG TEMPORARY_DEPS="gcc g++ clang fuse freetype tiff mesa linux-headers gettext-dev"
RUN apk add --update ${TEMPORARY_DEPS} curl make patch tar gawk autoconf automake python libtool git bison flex pkgconfig zip unzip gdb xz bash sudo file libintl findutils wget openssl ca-certificates

# We want to be able to do things like "source"
SHELL ["/bin/bash", "-c"]
ENV TERM="screen-256color"

# We still need a pretty recent cmake, so just build one from scratch like usual
INCLUDE lib/cmake_install
INCLUDE lib/patchelf_install

# Get our bash script library ready
COPY build_crosscompiler.sh /build.sh
COPY patches /downloads/patches

# GCC uses gnuisms for sha512sum. Fix that
RUN rm /usr/bin/sha512sum
COPY fake_sha512sum.sh /usr/bin/sha512sum
RUN /bin/busybox chmod +x /usr/bin/sha512sum

# build gcc for x86_64.  Use an especially old glibc version to maximize compatibility
ENV target="x86_64-linux-gnu"
ENV glibc_version=2.12.2
INCLUDE lib/linux_crosscompiler_install
ENV glibc_version=""

# build gcc for i686.  Again use an especially old glibc version to maximize compatibility
ENV target="i686-linux-gnu"
ENV L32="linux32"
ENV glibc_version=2.12.2
INCLUDE lib/linux_crosscompiler_install
ENV L32=""
ENV glibc_version=""

# build for mac64
ENV target="x86_64-apple-darwin14"
INCLUDE lib/osx_crosscompiler_install

# build for arm7/arm8
ENV target="aarch64-linux-gnu"
INCLUDE lib/linux_crosscompiler_install
ENV target="arm-linux-gnueabihf"
INCLUDE lib/linux_crosscompiler_install

# build gcc for ppc64le (we need a more recent glibc here as well)
# We require at least version 2.22 for the fixes to assembler problems:
# https://sourceware.org/bugzilla/show_bug.cgi?id=18116
# We require at least version 2.24 for the fixes to memset.S:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=843691
ENV target="powerpc64le-linux-gnu"
ENV glibc_version=2.25
INCLUDE lib/linux_crosscompiler_install
ENV glibc_version=""
ENV target=""

# build for win64/win32.  We use gcc 6.X, so that we stay with the old
# gfortran.3 ABI, not gfortran.4, as that doesn't work with our Julia builds.
ENV target="x86_64-w64-mingw32"
ENV gcc_version="6.4.0"
INCLUDE lib/win_crosscompiler_install
ENV target="i686-w64-mingw32"
INCLUDE lib/win_crosscompiler_install
ENV gcc_version=""

# Build gcc for musl linux.
ENV target="x86_64-linux-musl"
INCLUDE lib/linux_crosscompiler_install
ENV target="i686-linux-musl"
INCLUDE lib/linux_crosscompiler_install
ENV target="arm-linux-musleabihf"
INCLUDE lib/linux_crosscompiler_install
ENV target="aarch64-linux-musl"
INCLUDE lib/linux_crosscompiler_install
# This doesn't work yet, fails with "error: unsupported long double type"
#ENV target="powerpc64le-linux-musl"
#INCLUDE lib/linux_crosscompiler_install
ENV target=""

# We want a super binutils, so build it up
ARG binutils_configure_flags="--enable-targets=x86_64-linux-gnu,i686-linux-gnu,aarch64-linux-gnu,arm-linux-gnueabihf,powerpc64le-linux-gnu,x86_64-w64-mingw32,i686-w64-mingw32 --prefix=/opt/super_binutils"
INCLUDE lib/binutils_install

# We also occasionally use objconv
INCLUDE lib/objconv_install

# Install CMake toolchain files and patch CMake defaults
WORKDIR /
COPY cmake_toolchains /downloads/cmake_toolchains
RUN for f in /downloads/cmake_toolchains/*; do \
        cp -v $f /opt/$(basename ${f%.*})/; \
    done
RUN patch -p0 < /downloads/patches/cmake_install.patch

# Install sandbox
ADD https://raw.githubusercontent.com/JuliaPackaging/BinaryBuilder.jl/master/deps/sandbox.c /sandbox.c
#COPY sandbox.c sandbox.c
RUN /opt/x86_64-linux-gnu/bin/gcc -std=c99 -o /sandbox /sandbox.c
RUN rm -f /sandbox.c

# Override normal uname with something that fakes out based on ${target}
COPY fake_uname.sh /usr/local/bin/uname
RUN chmod +x /usr/local/bin/uname

# We need to override the ld conf to search /usr/local before /usr
RUN echo "/usr/local/lib64:/usr/local/lib:/lib:/usr/local/lib:/usr/lib" > /etc/ld-musl-x86_64.path

# Cleanup downloads and build.sh
RUN rm -rf /downloads /build.sh

# Remove bootstrapping compiler toolchain but keep libstdc++ and libgcc
RUN apk del ${TEMPORARY_DEPS}
RUN apk add libstdc++ libgcc

# Also install glibc, to do so we need to first import a packaging key
RUN curl -q -# -L https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub
RUN curl -q -# -L https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.26-r0/glibc-2.26-r0.apk -o /tmp/glibc.apk
RUN apk add /tmp/glibc.apk
RUN rm -f /tmp/glibc.apk

# Use /entrypoint.sh to conditionally apply ${L32} since we can't use ARG
# values within an actual ENTRYPOINT command.  :(
RUN echo "#!/bin/bash" > /entrypoint.sh; \
    echo "${L32} \"\$@\"" >> /entrypoint.sh; \
    chmod +x /entrypoint.sh

# Create /overlay_workdir so that we know we can always mount an overlay there
RUN mkdir /overlay_workdir

# Set default workdir
WORKDIR /workspace
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
