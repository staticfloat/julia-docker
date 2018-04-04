## Install tar
ARG tar_version=1.29
ARG tar_url=https://ftp.gnu.org/gnu/tar/tar-${tar_version}.tar.gz
WORKDIR /src

# Use download_unpack to download and unpack tar
RUN download_unpack.sh "${tar_url}"

# Build the tar sources!
WORKDIR /src/tar-${tar_version}
# Set CPPFLAGS because of this link: https://goo.gl/lKju1q
RUN $L32 ./configure --prefix=/usr/local CPPFLAGS="-fgnu89-inline"
RUN $L32 make -j4

# Install tar
USER root
RUN $L32 make install

# We need to pretend to be `gtar` as well
RUN ln -s /usr/local/bin/tar /usr/local/bin/gtar

# Now cleanup /src
WORKDIR /src
# Sigh, see https://github.com/docker/docker/issues/13451 for context
RUN rm -rf tar-${tar_version}* || \
    (mv tar-${tar_version}/confdir3/confdir3 tar-${tar_version}/confdir4 && \
    rm -rf tar-${tar_version}*)
