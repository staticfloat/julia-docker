## Install rr
ARG rr_version=4.5.0
ARG rr_url=https://github.com/mozilla/rr/archive/${rr_version}.tar.gz

USER root
# We need to install python's pexpect module for rr.  sigh.
RUN ${L32} pip install pexpect

USER buildworker
WORKDIR /src

# Use download_unpack to download and unpack rr
RUN download_unpack.sh "${rr_url}" /downloads/rr-${rr_version}.tar.gz

RUN mkdir -p /src/rr-${rr_version}/build/Release
WORKDIR /src/rr-${rr_version}/build/Release
RUN ${L32} cmake -DCMAKE_INSTALL_PREFIX=/usr/local -Ddisable32bit=TRUE ../..
RUN ${L32} make all -j4

# Install rr
USER root
RUN ${L32} make install

# cleanup /src
WORKDIR /src
RUN rm -rf rr-${rr_version}*
