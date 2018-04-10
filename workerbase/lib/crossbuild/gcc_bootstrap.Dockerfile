WORKDIR /src/gcc-${gcc_version}_bootstrap_build
RUN source /build.sh; \
    GCC_CONF_ARGS=""; \
    if [[ "${compiler_target}" == arm*hf ]]; then \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --with-float=hard"; \
    fi; \
    if [[ "${compiler_target}" == *-gnu* ]]; then \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --with-glibc-version=$(echo $glibc_version | cut -d '.' -f 1-2)"; \
    fi; \
    /src/gcc-${gcc_version}/configure \
        --prefix=/opt/${compiler_target} \
        --target=${compiler_target} \
        --host=${MACHTYPE} \
        --build=${MACHTYPE} \
        --disable-multilib \
        --disable-werror \
        --disable-shared \
        --disable-threads \
        --disable-libatomic \
        --disable-decimal-float \
        --disable-libffi \
        --disable-libgomp \
        --disable-libitm \
        --disable-libmpx \
        --disable-libquadmath \
        --disable-libssp \
        --disable-libsanitizer \
        --without-headers \
        --with-newlib \
        --disable-bootstrap \
        --enable-languages=c \
        --with-sysroot="$(get_sysroot)" \
        ${GCC_CONF_ARGS}

RUN make -j$(nproc)
RUN make install

# This is needed for any glibc older than 2.14, which includes the following commit
# https://sourceware.org/git/?p=glibc.git;a=commit;h=95f5a9a866695da4e038aa4e6ccbbfd5d9cf63b7
RUN ln -vs libgcc.a $(${compiler_target}-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/')

