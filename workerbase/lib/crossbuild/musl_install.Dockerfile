ARG musl_url="https://www.musl-libc.org/releases/musl-${musl_version}.tar.gz"
WORKDIR /src
RUN download_unpack.sh "${musl_url}"

# Build musl
WORKDIR /src/musl-${musl_version}_build
RUN source /build.sh; \
    /src/musl-${musl_version}/configure \
        --prefix=/usr \
        --host=${compiler_target} \
        --with-headers="$(get_sysroot)/usr/include" \
        --with-binutils=/opt/${compiler_target}/bin \
        --disable-multilib \
        --disable-werror \
        CROSS_COMPILE="${compiler_target}-"
RUN make -j$(nproc)
RUN source /build.sh; \
    make install DESTDIR="$(get_sysroot)"

# Cleanup
WORKDIR /src
RUN rm -rf musl-${musl_version}*
