RUN source /build.sh; set -e; install_kernel_headers
RUN source /build.sh; set -e; install_binutils
RUN source /build.sh; set -e; download_gcc
RUN source /build.sh; set -e; install_gcc_bootstrap

# If we're targeting a *-musl platform, install `musl` isntead of `glibc`
RUN source /build.sh; set -e; \
    if [[ ${target} == *-musl* ]]; then \
        install_musl; \
    else \
        install_glibc; \
    fi
RUN source /build.sh; set -e; install_gcc
