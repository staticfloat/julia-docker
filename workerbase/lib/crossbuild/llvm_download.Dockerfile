ARG llvm_ver=6.0.0

WORKDIR /src

# Download LLVM
ARG llvm_url=http://releases.llvm.org/${llvm_ver}/llvm-${llvm_ver}.src.tar.xz
RUN download_unpack.sh "${llvm_url}" && mv llvm-${llvm_ver}.src llvm-${llvm_ver}

# Download clang, libcxx and libcxxabi
WORKDIR /src/llvm-${llvm_ver}/projects
ARG clang_url=http://releases.llvm.org/${llvm_ver}/cfe-${llvm_ver}.src.tar.xz
RUN download_unpack.sh "${clang_url}" && mv cfe-${llvm_ver}.src clang
ARG libcxx_url=http://releases.llvm.org/${llvm_ver}/libcxx-${llvm_ver}.src.tar.xz
RUN download_unpack.sh "${libcxx_url}" && mv libcxx-${llvm_ver}.src libcxx
ARG libcxxabi_url=http://releases.llvm.org/${llvm_ver}/libcxxabi-${llvm_ver}.src.tar.xz
RUN download_unpack.sh "${libcxxabi_url}" && mv libcxxabi-${llvm_ver}.src libcxxabi
