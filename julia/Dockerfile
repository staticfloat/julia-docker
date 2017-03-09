FROM debian

# This contains the MARCH and JULIA_CPU_TARGET etc... flags
ARG ARCH_FLAGS

# These are the build dependencies for Julia
ARG BUILD_DEPS="build-essential gfortran m4 python cmake curl git"
RUN apt update && apt install -y ${BUILD_DEPS}

# Clone julia, build and install
RUN git clone https://github.com/JuliaLang/julia.git /julia_build
RUN cd /julia_build && make -j4 ${ARCH_FLAGS} install

# Cleanup afterward
RUN rm -rf /julia_build
RUN apt remove -y ${BUILD_DEPS}; apt autoremove -y; apt-get -y clean
RUN apt-get -y purge; rm -rf /var/lib/apt/lists/*
