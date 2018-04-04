USER root
# Install binfmt-support
RUN [ -z $(which apt-get 2>/dev/null) ] || apt-get install -y binfmt-support

# Download latest qemu-user-static releases
ARG qemu_version=2.11.0
RUN curl -L https://github.com/multiarch/qemu-user-static/releases/download/v${qemu_version}/qemu-${qemu_arch}-static -o /usr/bin/qemu-${qemu_arch}-static
RUN chmod +x /usr/bin/qemu-${qemu_arch}-static
