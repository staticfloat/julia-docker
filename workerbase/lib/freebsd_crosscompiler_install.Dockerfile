INCLUDE crossbuild/freebsd_components_install

# This doesn't work yet, isl fails to build with:
# configure: error: No ffs implementation found
INCLUDE crossbuild/binutils_install
INCLUDE crossbuild/gcc_download
INCLUDE crossbuild/gcc_install

INCLUDE crossbuild/llvm_download
INCLUDE crossbuild/llvm_clang_install

# Install cmake toolchain
COPY cmake_toolchains/${compiler_target}.toolchain /opt/${compiler_target}/
