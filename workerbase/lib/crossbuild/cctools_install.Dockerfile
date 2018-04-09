ARG cctools_url=https://github.com/tpoechtrager/cctools-port/archive/${cctools_version}.tar.gz
WORKDIR /src
RUN download_unpack.sh "${cctools_url}"

WORKDIR /src/cctools-port-${cctools_version}
# Fix build on musl (https://github.com/tpoechtrager/cctools-port/pull/36)
COPY patches/cctools_musl.patch /tmp/
RUN patch -p1 < /tmp/cctools_musl.patch; \
    rm -f /tmp/cctools_musl.patch

# Install cctools
WORKDIR /src/cctools-port-${cctools_version}/cctools
RUN rm -f aclocal.m4
RUN aclocal
RUN libtoolize --force
RUN automake --add-missing --force
RUN autoreconf
RUN ./autogen.sh

RUN ./configure \
        --target=${compiler_target} \
        --prefix=/opt/${compiler_target} \
        --disable-clang-as \
        --with-libtapi=/opt/${compiler_target}
RUN make -j$(nproc)
RUN make install

# Cleanup
WORKDIR /src
RUN rm -rf cctools-port-${cctools_version}
