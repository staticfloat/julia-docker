ARG gcc_url=https://mirrors.kernel.org/gnu/gcc/gcc-${gcc_version}/gcc-${gcc_version}.tar.xz

# Download and unpack gcc and prereqs
WORKDIR /src
RUN download_unpack.sh "${gcc_url}"
WORKDIR /src/gcc-${gcc_version}

# Download prerequisites, then update config.{guess,sub} for all subprojects
RUN contrib/download_prerequisites
RUN update_configure_scripts
