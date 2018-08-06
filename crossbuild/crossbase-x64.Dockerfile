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
RUN apk add --update curl make patch tar gawk autoconf automake python libtool git bison flex pkgconfig zip unzip gdb xz bash sudo file libintl findutils wget openssl ca-certificates libstdc++ libgcc python pv

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
INCLUDE lib/ccache_install
RUN apk del gcc g++

# We want to be able to do things like "source"
SHELL ["/bin/bash", "-c"]
ENV TERM="screen-256color"
RUN echo "alias ll='ls -la'" >> /root/.bashrc

# We need to override the ld conf to search /usr/local before /usr
RUN echo "/usr/local/lib64:/usr/local/lib:/lib:/usr/local/lib:/usr/lib" > /etc/ld-musl-x86_64.path

# Create /overlay_workdir so that we know we can always mount an overlay there.  Same with /meta
RUN mkdir /overlay_workdir /meta


## Create "builder" stage that just contains a bunch of stuff we need to build
# our cross-compilers, but aren't actually runtime requirements
FROM base as shard_builder
RUN apk add clang gcc g++ fuse freetype tiff mesa linux-headers gettext-dev libgcc

# Build the sandbox toward the end, so that if we need to iterate on this we don't disturb the
# shards (which are built off of the `shard_builder` above. 
FROM shard_builder as sandbox_builder
ADD https://raw.githubusercontent.com/JuliaPackaging/BinaryBuilder.jl/8a5fdcc7c4bad920b924e68c4ffe438ddc35b930/deps/sandbox.c /sandbox.c
RUN gcc -static -std=c99 -o /sandbox /sandbox.c; rm -f /sandbox.c

## Create "crossbuild" stage that contains "sandbox" and is slightly cleaned up
FROM base as crossbuild
COPY --from=sandbox_builder /sandbox /sandbox
RUN rm -rf /downloads /build.sh

# Set default workdir
WORKDIR /workspace
CMD ["/bin/bash"]
