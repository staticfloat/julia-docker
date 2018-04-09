FROM alpine:latest as base

## First, setup base system with our special commands and tools and whatnot
# These are where we'll do all our work, so make them now
RUN mkdir -p /src /downloads

# Get our bash script library ready
COPY crossbuild/build.sh /build.sh

# We use the "download_unpack.sh" command a lot, we need a `tar` wrapper to insert
# extra command line flags on every `tar` command, we have an `update_configure_scripts`
# command, and we fake out `uname` depending on the value of `$target`. GCC uses
# gnuisms for sha512sum, so we need to work around that as well.
COPY download_unpack.sh /usr/local/bin
COPY tar_wrapper.sh /usr/local/bin/tar
COPY update_configure_scripts.sh /usr/local/bin/update_configure_scripts
COPY fake_uname.sh /usr/local/bin/uname
RUN rm /usr/bin/sha512sum
COPY fake_sha512sum.sh /usr/local/bin/sha512sum

RUN chmod +x /usr/local/bin/*

# Install build tools
RUN apk add --update curl make patch tar gawk autoconf automake python libtool git bison flex pkgconfig zip unzip gdb xz bash sudo file libintl findutils wget openssl ca-certificates libstdc++ libgcc python

# Also install glibc, to do so we need to first import a packaging key
RUN curl -q -# -L https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub
RUN curl -q -# -L https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.26-r0/glibc-2.26-r0.apk -o /tmp/glibc.apk
RUN apk add /tmp/glibc.apk; rm -f /tmp/glibc.apk

# Install a few tools from scratch, and patch cmake defaults
RUN apk add gcc g++
INCLUDE lib/cmake_install
INCLUDE lib/patchelf_install
INCLUDE lib/super_binutils_install
INCLUDE lib/objconv_install
RUN apk del gcc g++

# We want to be able to do things like "source"
SHELL ["/bin/bash", "-c"]
ENV TERM="screen-256color"
RUN echo "alias ll='ls -la'" >> /root/.bashrc

## Create "builder" image that just contains a bunch of stuff we need to build
# our cross-compilers, but aren't actually runtime requirements
FROM base as shard_builder
RUN apk add gcc g++ clang fuse freetype tiff mesa linux-headers gettext-dev

# build gcc for x86_64.  Use an especially old glibc version to maximize compatibility
FROM shard_builder as shard_x86_64-linux-gnu
INCLUDE lib/crossbuild/version_defaults
ARG glibc_version=2.12.2
ARG compiler_target="x86_64-linux-gnu"
INCLUDE lib/linux_glibc_crosscompiler_install

# build gcc for i686.  Again use an especially old glibc version to maximize compatibility
FROM shard_builder as shard_i686-linux-gnu
INCLUDE lib/crossbuild/version_defaults
ARG glibc_version=2.12.2
ARG compiler_target="i686-linux-gnu"
INCLUDE lib/linux_glibc_crosscompiler_install

# build for mac64
FROM shard_builder as shard_x86_64-apple-darwin14
INCLUDE lib/crossbuild/version_defaults
ARG compiler_target="x86_64-apple-darwin14"
INCLUDE lib/osx_crosscompiler_install

# build for arm7/arm8
FROM shard_builder as shard_aarch64-linux-gnu
INCLUDE lib/crossbuild/version_defaults
ARG compiler_target="aarch64-linux-gnu"
INCLUDE lib/linux_glibc_crosscompiler_install
FROM shard_builder as shard_arm-linux-gnueabihf
INCLUDE lib/crossbuild/version_defaults
ARG compiler_target="arm-linux-gnueabihf"
INCLUDE lib/linux_glibc_crosscompiler_install

# build gcc for ppc64le (we need a more recent glibc here as well)
# We require at least version 2.22 for the fixes to assembler problems:
# https://sourceware.org/bugzilla/show_bug.cgi?id=18116
# We require at least version 2.24 for the fixes to memset.S:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=843691
FROM shard_builder as shard_powerpc64le-linux-gnu
INCLUDE lib/crossbuild/version_defaults
ARG compiler_target="powerpc64le-linux-gnu"
ARG glibc_version=2.25
INCLUDE lib/linux_glibc_crosscompiler_install

# build for win64/win32.  We use gcc 6.X, so that we stay with the old
# gfortran.3 ABI, not gfortran.4, as that doesn't work with our Julia builds.
FROM shard_builder as shard_x86_64-w64-mingw32
INCLUDE lib/crossbuild/version_defaults
ARG compiler_target="x86_64-w64-mingw32"
ARG gcc_version="6.4.0"
INCLUDE lib/win_crosscompiler_install
FROM shard_builder as shard_i686-w64-mingw32
INCLUDE lib/crossbuild/version_defaults
ARG compiler_target="i686-w64-mingw32"
ARG gcc_version="6.4.0"
INCLUDE lib/win_crosscompiler_install

# Build gcc for musl linux.
FROM shard_builder as shard_x86_64-linux-musl
INCLUDE lib/crossbuild/version_defaults
ARG compiler_target="x86_64-linux-musl"
INCLUDE lib/linux_musl_crosscompiler_install
FROM shard_builder as shard_i686-linux-musl
INCLUDE lib/crossbuild/version_defaults
ARG compiler_target="i686-linux-musl"
INCLUDE lib/linux_musl_crosscompiler_install
FROM shard_builder as shard_arm-linux-musleabihf
INCLUDE lib/crossbuild/version_defaults
ARG compiler_target="arm-linux-musleabihf"
INCLUDE lib/linux_musl_crosscompiler_install
FROM shard_builder as shard_aarch64-linux-musl
INCLUDE lib/crossbuild/version_defaults
ARG compiler_target="aarch64-linux-musl"
INCLUDE lib/linux_musl_crosscompiler_install




# Copy all our built shards into one ginormous image
FROM base as crossbuild
COPY --from=shard_x86_64-linux-gnu /opt/x86_64-linux-gnu /opt/x86_64-linux-gnu
COPY --from=shard_i686-linux-gnu /opt/i686-linux-gnu /opt/i686-linux-gnu
COPY --from=shard_aarch64-linux-gnu /opt/aarch64-linux-gnu /opt/aarch64-linux-gnu
COPY --from=shard_arm-linux-gnueabihf /opt/arm-linux-gnueabihf /opt/arm-linux-gnueabihf
COPY --from=shard_powerpc64le-linux-gnu /opt/powerpc64le-linux-gnu /opt/powerpc64le-linux-gnu
COPY --from=shard_x86_64-apple-darwin14 /opt/x86_64-apple-darwin14 /opt/x86_64-apple-darwin14
COPY --from=shard_x86_64-w64-mingw32 /opt/x86_64-w64-mingw32 /opt/x86_64-w64-mingw32
COPY --from=shard_i686-w64-mingw32 /opt/i686-w64-mingw32 /opt/i686-w64-mingw32
COPY --from=shard_x86_64-linux-musl /opt/x86_64-linux-musl /opt/x86_64-linux-musl
COPY --from=shard_i686-linux-musl /opt/i686-linux-musl /opt/i686-linux-musl
COPY --from=shard_arm-linux-musleabihf /opt/arm-linux-musleabihf /opt/arm-linux-musleabihf
COPY --from=shard_aarch64-linux-musl /opt/aarch64-linux-musl /opt/aarch64-linux-musl

# Install sandbox, using x86_64-linux-gnu compiler
ADD https://raw.githubusercontent.com/JuliaPackaging/BinaryBuilder.jl/master/deps/sandbox.c /sandbox.c
RUN /opt/x86_64-linux-gnu/bin/gcc -std=c99 -o /sandbox /sandbox.c; rm -f /sandbox.c

# We need to override the ld conf to search /usr/local before /usr
RUN echo "/usr/local/lib64:/usr/local/lib:/lib:/usr/local/lib:/usr/lib" > /etc/ld-musl-x86_64.path

# Cleanup downloads and build.sh
RUN rm -rf /downloads /build.sh

# Create /overlay_workdir so that we know we can always mount an overlay there
RUN mkdir /overlay_workdir

# Set default workdir
WORKDIR /workspace
CMD ["/bin/bash"]
