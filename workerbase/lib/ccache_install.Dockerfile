## Install ccache
ARG ccache_version=3.3.4
ARG ccache_url=https://www.samba.org/ftp/ccache/ccache-${ccache_version}.tar.xz

WORKDIR /src

# Use download_unpack to download and unpack ccache
RUN download_unpack.sh "${ccache_url}"

WORKDIR /src/ccache-${ccache_version}
# We need to patch ccache's configure system since it's ancient
RUN ${L32} curl -L 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess' -o config.guess
RUN ${L32} curl -L 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub' -o config.sub
RUN ${L32} ./configure --prefix=/usr/local
RUN ${L32} make all -j4

# Install ccache
USER root
RUN ${L32} make install

# cleanup /src
WORKDIR /src
RUN rm -rf ccache-${ccache_version}
