ARG llvm_ver=6.0.0

WORKDIR /src

# Download LLVM
ARG llvm_url=http://releases.llvm.org/${llvm_ver}/llvm-${llvm_ver}.src.tar.xz
RUN download_unpack.sh "${llvm_url}" && mv llvm-${llvm_ver}.src llvm-${llvm_ver}

# Download clang.  It's a special snowflake and gets put into tools/clang
WORKDIR /src/llvm-${llvm_ver}/tools
ARG clang_url=http://releases.llvm.org/${llvm_ver}/cfe-${llvm_ver}.src.tar.xz
RUN download_unpack.sh "${clang_url}" && mv cfe-${llvm_ver}.src clang

# Download libcxx, libcxxabi and compiler_rt
WORKDIR /src/llvm-${llvm_ver}/projects
ARG libcxx_url=http://releases.llvm.org/${llvm_ver}/libcxx-${llvm_ver}.src.tar.xz
RUN download_unpack.sh "${libcxx_url}" && mv libcxx-${llvm_ver}.src libcxx
ARG libcxxabi_url=http://releases.llvm.org/${llvm_ver}/libcxxabi-${llvm_ver}.src.tar.xz
RUN download_unpack.sh "${libcxxabi_url}" && mv libcxxabi-${llvm_ver}.src libcxxabi
ARG compiler_rt_url=http://releases.llvm.org/${llvm_ver}/compiler-rt-${llvm_ver}.src.tar.xz
RUN download_unpack.sh "${compiler_rt_url}" && mv compiler-rt-${llvm_ver}.src compiler-rt
