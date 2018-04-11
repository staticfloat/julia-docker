ARG freebsd_url="https://download.freebsd.org/ftp/releases/amd64/${freebsd_version}-RELEASE/base.txz"

WORKDIR /src/freebsd-${freebsd_version}
RUN download_unpack.sh "${freebsd_url}"

# Copy over the things we need for our bootstrapping
RUN source /build.sh; \
    bsdroot="$(get_sysroot)"; \
    mkdir -p "${bsdroot}/lib"; \
    mv usr/include "${bsdroot}"; \
    mv usr/lib "${bsdroot}"; \
    mv lib/* "${bsdroot}/lib"; \
    mkdir -p "${bsdroot}/usr"; \
    ln -sf "${bsdroot}/include" "${bsdroot}/usr/"; \
    ln -sf "${bsdroot}/lib" "${bsdroot}/usr/"; \
    ln -sf "${bsdroot}/lib/libgcc_s.so.1" "${bsdroot}/lib/libgcc_s.so"; \
    ln -sf "${bsdroot}/lib/libcxxrt.so.1" "${bsdroot}/lib/libcxxrt.so"

# Cleanup
WORKDIR /src
RUN rm -rf freebsd-${freebsd_version}*
