# Install docker static binary
USER root
WORKDIR /usr/local
ARG docker_version="17.12.1-ce"
RUN M="$(uname -m)"; \
    if [[ "$M" == "i686" ]]; then \
        M="x86_64"; \
    fi; \
    if [[ "$M" == "armv7l" ]]; then \
        M="armhf"; \
    fi; \
    download_unpack "https://download.docker.com/linux/static/stable/${M}/docker-${docker_version}.tgz"

# Copy across docker executables we need
RUN mv docker/docker bin/

# Remove docker executables we don't need
RUN rm -rf docker

# Install docker-compose
RUN pip install docker-compose
