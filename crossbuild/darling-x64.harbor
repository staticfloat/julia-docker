# Build an image that contains all of our cross compilers and all that stuff.
# Since we need virtually everything within the actual workerbase image, just
# build off of that one instead of compiling it all over again
FROM ubuntu:trusty

# Setup a few things we need in order to make it through the build properly
INCLUDE lib/alpha

# Install build tools (BUILD_TOOLS are things needed during the build, but not at runtime)
ARG TEMPORARY_DEPS="build-essential gobjc gobjc++ clang libfuse-dev libfreetype6-dev libtiff-dev libgl1-mesa-dev linux-headers-generic"
RUN apt update && apt install -y ${TEMPORARY_DEPS} sudo curl make patch tar gawk autoconf python libtool git bison flex pkg-config zip unzip gdb
RUN echo "buildworker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN sed -i.bak -e 's/Defaults[[:space:]]*env_reset//g' /etc/sudoers
RUN sed -i.bak -e 's/Defaults[[:space:]]*secure_path=.*//g' /etc/sudoers
USER buildworker

INCLUDE lib/cmake_install

# Get our bash script library ready
COPY build_crosscompiler.sh /build.sh
COPY patches /downloads/patches

USER root
RUN apt install -y linux-headers-generic

# build osx cross-compiler
ENV target="x86_64-apple-darwin14"
USER buildworker
WORKDIR /src
RUN git clone --recursive https://github.com/darlinghq/darling.git
RUN mkdir -p /src/darling/build
#ENV linux_version=${linux_version:-4.12}
#RUN source /build.sh; install_kernel_headers
WORKDIR /src/darling/build
RUN cmake .. -DCMAKE_TOOLCHAIN_FILE=../Toolchain.cmake -DCMAKE_INSTALL_PREFIX=/opt/${target}
RUN make V=1 VERBOSE=1

# Override normal uname with something that fakes out based on ${target}
USER root
COPY fake_uname.sh /usr/local/bin/uname
RUN chmod +x /usr/local/bin/uname

INCLUDE lib/omega
