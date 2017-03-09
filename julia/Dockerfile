FROM ubuntu:16.04

# This contains the MARCH and JULIA_CPU_TARGET etc... flags
ARG ARCH_FLAGS

# These are the build dependencies for Julia
ARG BUILD_DEPS="build-essential gfortran m4 python cmake curl git patchelf"
RUN apt update && apt install -y ${BUILD_DEPS}

# Clone julia, build and install
RUN git clone https://github.com/JuliaLang/julia.git /julia_build
RUN cd /julia_build && make -j4 ${ARCH_FLAGS} prefix=/usr install

# Run fixup-libgfortran so that we store away our necessary libraries
# before uninstalling libgfortran
RUN /julia_build/contrib/fixup-libgfortran.sh /usr/lib/julia/

# Cleanup afterward
RUN rm -rf /julia_build
RUN apt remove -y ${BUILD_DEPS}; apt autoremove -y; apt-get -y clean
RUN apt-get -y purge; rm -rf /var/lib/apt/lists/*

CMD ["/usr/bin/julia"]
