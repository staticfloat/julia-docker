## Install tar
ARG patchelf_version=0.9
ARG patchelf_url=https://github.com/NixOS/patchelf/archive/${patchelf_version}.tar.gz

WORKDIR /src

# Use download_unpack to download and unpack patchelf
RUN download_unpack.sh "${patchelf_url}"

# Build the patchelf sources!
WORKDIR /src/patchelf-${patchelf_version}
RUN $L32 ./bootstrap.sh
RUN $L32 ./configure --prefix=/usr/local
RUN $L32 make -j4

# Install patchelf
USER root
RUN $L32 make install

# Now cleanup /src
WORKDIR /src
RUN rm -rf patchelf-${patchelf_version}*
