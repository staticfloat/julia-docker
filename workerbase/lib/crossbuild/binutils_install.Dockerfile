ARG binutils_url=https://ftp.gnu.org/gnu/binutils/binutils-${binutils_version}.tar.bz2

WORKDIR /src
RUN download_unpack.sh "${binutils_url}"

# Build binutils!
WORKDIR /src/binutils-${binutils_version}
RUN source /build.sh; \
    ./configure \
        --prefix=/opt/${compiler_target} \
        --target=${compiler_target} \
        --with-sysroot="$(get_sysroot)" \
        --enable-multilib \
        --disable-werror
RUN  make -j$(nproc)

# Install binutils
RUN make install

# Cleanup
WORKDIR /src
RUN rm -rf binutils-${binutils_version}
