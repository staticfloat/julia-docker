ARG qemu_version=2.12.0
ARG qemu_archs="aarch64 arm ppc64le x86_64 i386"
RUN for qemu_arch in ${qemu_archs}; do \
        curl -L https://github.com/multiarch/qemu-user-static/releases/download/v${qemu_version}/qemu-${qemu_arch}-static -o /usr/bin/qemu-${qemu_arch}-static; \
        chmod +x /usr/bin/qemu-${qemu_arch}-static; \
    done

