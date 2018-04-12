ARG dsymutil_url=https://github.com/tpoechtrager/llvm-dsymutil/archive/${dsymutil_version}.tar.gz

WORKDIR /src
RUN download_unpack.sh "${dsymutil_url}"

WORKDIR /src/llvm-dsymutil-${dsymutil_version}

# Backport of https://reviews.llvm.org/D39297 to fix build on musl
COPY patches/dsymutil_llvm_dynlib.patch /tmp/
RUN patch -p1 < /tmp/dsymutil_llvm_dynlib.patch; \
    rm -f /tmp/dsymutil_llvm_dynlib.patch

# Make this `ar` able to use `-rcu`
COPY patches/llvm_ar_options.patch /tmp/
RUN patch -p1 < /tmp/llvm_ar_options.patch; \
    rm -f /tmp/llvm_ar_options.patch

# Install dsymutil
WORKDIR /src/llvm-dsymutil-${dsymutil_version}/build
RUN cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DLLVM_ENABLE_ASSERTIONS=Off
RUN make -f tools/dsymutil/Makefile -j$(nproc)
RUN cp bin/llvm-dsymutil /opt/${compiler_target}/bin/dsymutil
RUN make -f tools/llvm-ar/Makefile -j$(nproc)
RUN cp bin/llvm-ar /opt/${compiler_target}/bin/${compiler_target}-ar
RUN cp bin/llvm-ranlib /opt/${compiler_target}/bin/${compiler_target}-ranlib

# Cleanup
WORKDIR /src
RUN rm -rf llvm-dsymutil-${dsymutil_version}
