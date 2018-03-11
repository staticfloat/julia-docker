MAINTAINER Elliot Saba <staticfloat@gmail.com>
USER root

# We create a `buildworker` user so that we don't have to run everything as root
RUN useradd -u 1337 -m -s /bin/bash buildworker || true

# These are where we'll do all our work, so make them now
RUN mkdir -p /src /downloads
RUN chown buildworker:buildworker /src /downloads

# We use the "download_unpack.sh" command a lot, throw it into /usr/bin
COPY download_unpack.sh /usr/bin

# Add ourselves to sudoers
RUN mkdir -p /etc/sudoers.d
RUN echo "buildworker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/buildworker

# Vim needs to work with arrow keys
RUN echo "set nocompatible" > /home/buildworker/.vimrc && chown buildworker:buildworker /home/buildworker/.vimrc
ENV TERM=screen

# We want to be able to do things like "source"
SHELL ["/bin/bash", "-c"]
