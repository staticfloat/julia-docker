ENV PATH="/opt/${compiler_target}/bin:$PATH"
INCLUDE crossbuild/kernel_headers_install
INCLUDE crossbuild/binutils_install
INCLUDE crossbuild/gcc_download
INCLUDE crossbuild/gcc_bootstrap
INCLUDE crossbuild/musl_install
INCLUDE crossbuild/gcc_install

# Install cmake toolchain
COPY cmake_toolchains/${compiler_target}.toolchain /opt/${compiler_target}/
