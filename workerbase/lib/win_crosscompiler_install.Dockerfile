ENV PATH="/opt/${compiler_target}/bin:$PATH"
INCLUDE crossbuild/binutils_install
INCLUDE crossbuild/mingw_stage1
INCLUDE crossbuild/gcc_download
INCLUDE crossbuild/gcc_bootstrap
INCLUDE crossbuild/mingw_stage2
INCLUDE crossbuild/gcc_install

# Install cmake toolchain
COPY cmake_toolchains/${compiler_target}.toolchain /opt/${compiler_target}/
