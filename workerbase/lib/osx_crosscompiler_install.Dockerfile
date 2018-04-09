RUN source /build.sh; set -e; install_osx_sdk
RUN source /build.sh; set -e; install_libtapi
RUN source /build.sh; set -e; install_cctools
RUN source /build.sh; set -e; install_dsymutil
RUN source /build.sh; set -e; download_llvm
RUN source /build.sh; set -e; install_clang
RUN source /build.sh; set -e; download_gcc
RUN source /build.sh; set -e; install_gcc

# Install cmake toolchain
COPY cmake_toolchains/${compiler_target}.toolchain /opt/${compiler_target}/
