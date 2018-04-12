ARG libtapi_url=https://github.com/tpoechtrager/apple-libtapi/archive/${libtapi_version}.tar.gz

WORKDIR /src
RUN download_unpack.sh "${libtapi_url}"
WORKDIR /src/apple-libtapi-${libtapi_version}

# Backport of https://reviews.llvm.org/D39297 to fix build on musl
COPY patches/libtapi_llvm_dynlib.patch /tmp/
RUN patch -p1 < /tmp/libtapi_llvm_dynlib.patch; \
    rm -f /tmp/libtapi_llvm_dynlib.patch

# Build and install libtapi (We have to tell it to explicitly use clang)
RUN export MACOSX_DEPLOYMENT_TARGET=10.10; \
    export CC="/usr/bin/clang"; \
    export CXX="/usr/bin/clang++"; \
    INSTALLPREFIX=/opt/${compiler_target} ./build.sh; \
    INSTALLPREFIX=/opt/${compiler_target} ./install.sh

    # Cleanup
WORKDIR /src
RUN rm -rf apple-libtapi-${libtapi_version}
