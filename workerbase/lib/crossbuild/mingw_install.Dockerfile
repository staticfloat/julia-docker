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

# If we're building a 32-bit build of mingw, add `--disable-lib64`
WORKDIR /src/mingw-w64-v${mingw_version}-crt_build
RUN MINGW_CONF_ARGS=""; \
    if [[ "${compiler_target}" == i686-* ]]; then \
        MINGW_CONF_ARGS="${MINGW_CONF_ARGS} --disable-lib64"; \
    else \
        MINGW_CONF_ARGS="${MINGW_CONF_ARGS} --disable-lib32"; \
    fi; \
    /src/mingw-w64-v${mingw_version}/mingw-w64-crt/configure \
        --prefix=/opt/${compiler_target}/${compiler_target} \
        --host=${compiler_target} \
        ${MINGW_CONF_ARGS}

# Install crt
RUN make -j${nproc}
RUN make install

# Install winpthreads
WORKDIR /src/mingw-w64-v${mingw_version}-winpthreads_build
RUN /src/mingw-w64-v${mingw_version}/mingw-w64-libraries/winpthreads/configure \
        --prefix=/opt/${compiler_target}/${compiler_target} \
        --host=${compiler_target} \
        --enable-static \
        --enable-shared
RUN make -j${nproc}
RUN make install

# Cleanup
WORKDIR /src
RUN rm -rf mingw-w64-v${mingw_version}*
