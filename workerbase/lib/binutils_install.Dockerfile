## Install binutils
ARG binutils_version=2.29.1
ARG binutils_url=https://ftp.gnu.org/gnu/binutils/binutils-${binutils_version}.tar.xz

# Use download_unpack to download and unpack binutils and gcc
WORKDIR /src
RUN download_unpack.sh "${binutils_url}"

# Build binutils!  Because it's cheap and easy, we enable essentially every
# target under the sun for binutils
WORKDIR /src/binutils-${binutils_version}
RUN ${L32} ./configure --prefix=/usr/local \
                       ${binutils_configure_flags}
RUN ${L32} make -j4

# Install binutils
USER root
RUN ${L32} make install

# Cleanup
WORKDIR /src
RUN rm -rf binutils-${binutils_version}
