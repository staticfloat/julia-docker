ARG linux_url=http://www.kernel.org/pub/linux/kernel/v4.x/linux-${linux_version}.tar.xz

WORKDIR /src
RUN download_unpack.sh "${linux_url}"
WORKDIR /src/linux-${linux_version}
RUN source /build.sh && \
    ARCH="$(target_to_linux_arch ${compiler_target})" && \
    make ARCH=${ARCH} mrproper && \
    make ARCH=${ARCH} headers_check && \
    make INSTALL_HDR_PATH=$(get_sysroot)/usr ARCH=${ARCH} V=0 headers_install

# Cleanup
WORKDIR /src
RUN rm -rf linux-${linux_version}
