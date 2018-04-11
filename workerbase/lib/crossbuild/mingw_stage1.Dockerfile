ARG mingw_url=https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/mingw-w64-v${mingw_version}.tar.bz2

WORKDIR /src
RUN download_unpack.sh "${mingw_url}"

# Patch mingw to build 32-bit cross compiler with GCC 7.1+
WORKDIR /src/mingw-w64-v${mingw_version}
COPY patches/mingw_gcc710_i686.patch /tmp/
RUN patch -p1 < /tmp/mingw_gcc710_i686.patch; \
    rm -f /tmp/mingw_gcc710_i686.patch

# Install mingw headers
WORKDIR /src/mingw-w64-v${mingw_version}/mingw-w64-headers
RUN ./configure \
        --prefix=/opt/${compiler_target}/${compiler_target} \
        --enable-sdk=all \
        --enable-secure-api \
        --host=${compiler_target}
RUN make install
