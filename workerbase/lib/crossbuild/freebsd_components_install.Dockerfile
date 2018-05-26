ARG freebsd_url="https://download.freebsd.org/ftp/releases/amd64/${freebsd_version}-RELEASE/base.txz"

WORKDIR /src/freebsd-${freebsd_version}
RUN download_unpack.sh "${freebsd_url}"

# Copy over the things we need for our bootstrapping
RUN source /build.sh; \
    sysroot="$(get_sysroot)"; \
    mkdir -p "${sysroot}"; \
    mv usr/include "${sysroot}"; \
    mv usr/lib "${sysroot}"; \
    mv lib/* "${sysroot}/lib"; \
    mkdir -p "${sysroot}/usr"; \
    ln -sf "${sysroot}/include" "${sysroot}/usr/"; \
    ln -sf "${sysroot}/lib" "${sysroot}/usr/"; \
    ln -sf "libgcc_s.so.1" "${sysroot}/lib/libgcc_s.so"; \
    ln -sf "libcxxrt.so.1" "${sysroot}/lib/libcxxrt.so"

# Many symlinks exist that point to `../../lib/libfoo.so`.
# We need them to point to just `libfoo.so`. :P
RUN for f in $(find "/opt/${target}" -xtype l); do \
    link_target="$(readlink "$f")"; \
    if [[ -n $(echo "${link_target}" | grep "^../../lib") ]]; then \
        ln -vsf "${link_target#../../lib/}" "${f}"; \
    fi; \
done

# Cleanup
WORKDIR /src
RUN rm -rf freebsd-${freebsd_version}*
