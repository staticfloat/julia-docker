ENV PATH="/opt/${compiler_target}/bin:$PATH"
INCLUDE crossbuild/osx_sdk_install
INCLUDE crossbuild/libtapi_install
INCLUDE crossbuild/cctools_install
INCLUDE crossbuild/dsymutil_install
INCLUDE crossbuild/llvm_download
INCLUDE crossbuild/llvm_clang_install
INCLUDE crossbuild/gcc_download
INCLUDE crossbuild/gcc_install

# Install cmake toolchain
COPY cmake_toolchains/${compiler_target}.toolchain /opt/${compiler_target}/
