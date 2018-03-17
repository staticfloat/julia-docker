## Install libtool
ARG libtool_version=2.4.6
ARG libtool_url=http://ftpmirror.gnu.org/libtool/libtool-${libtool_version}.tar.gz
WORKDIR /src

# Use download_unpack to download and unpack libtool
RUN download_unpack.sh "${libtool_url}"
WORKDIR /src/libtool-${libtool_version}
RUN ${L32} ./configure --prefix=/usr/local
RUN ${L32} make all -j4

# Install libtool
USER root
RUN ${L32} make install

# cleanup /src
WORKDIR /src
RUN rm -rf libtool-${libtool_version}
