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
RUN make -j$(nproc)
RUN make install

# Install winpthreads
WORKDIR /src/mingw-w64-v${mingw_version}-winpthreads_build
RUN /src/mingw-w64-v${mingw_version}/mingw-w64-libraries/winpthreads/configure \
        --prefix=/opt/${compiler_target}/${compiler_target} \
        --host=${compiler_target} \
        --enable-static \
        --enable-shared
RUN make -j$(nproc)
RUN make install

# Cleanup
WORKDIR /src
RUN rm -rf mingw-w64-v${mingw_version}*
