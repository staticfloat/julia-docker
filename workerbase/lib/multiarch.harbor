USER root
# Install binfmt-support
RUN [ -z $(which apt-get 2>/dev/null) ] || apt-get install -y binfmt-support

# Download latest qemu-user-static releases
ARG QEMU_VER=2.8.3
RUN curl -L https://github.com/multiarch/qemu-user-static/releases/download/v${QEMU_VER}/qemu-${QEMU_ARCH}-static -o /usr/bin/qemu-${QEMU_ARCH}-static
RUN chmod +x /usr/bin/qemu-${QEMU_ARCH}-static
