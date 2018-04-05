RUN source /build.sh; set -e; download_llvm
RUN source /build.sh; set -e; install_clang
RUN source /build.sh; set -e; install_freebsd_components
