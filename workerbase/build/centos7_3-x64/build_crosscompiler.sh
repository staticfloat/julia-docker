#!/bin/bash

## To build a cross-compiler for linux targets we:
# 1) Download kernel headers
# 2) Install binutils
# 3) Install a C compiler
# 4) Get glibc headers
# 5) Install libgcc
# 6) Install the rest of glibc
# 7) Build a complete gcc/gfortran

# These steps are given by the following bash functions:
#   install_kernel_headers
#   install_binutils
#   install_gcc_stage1
#   install_glibc_stage1
#   install_gcc_stage2
#   install_glibc_stage2
#   install_gcc_stage3
#
# Ensure that you have set the following environment variables:
#   target
#   linux_version
#   binutils_version
#   gcc_version
#   glibc_version


## To build a cross-compile for OSX targets we:
# 1) Download OSX SDK
# 2) Install libtapi
# 3) Install cctools
# 4) Install dsymutil
# 5) Install gcc
## These steps are given by the following bash functions:
#   install_osx_sdk
#   install_libtapi
#   install_cctools
#   install_dsymutil
#   install_gcc
#
# Ensure that you have set the following environment variables:
#   target
#   libtapi_version
#   cctools_version
#   dsymutil_version
#   gcc_version

## Function to take in a target such as `aarch64-linux-gnu`` and spit out a
## linux kernel arch like "arm64".
target_to_linux_arch()
{
    case "$1" in
        arm*)
            echo "arm"
            ;;
        aarch64*)
            echo "arm64"
            ;;
        powerpc*)
            echo "powerpc"
            ;;
        i686*)
            echo "x86"
            ;;
        x86*)
            echo "x86"
            ;;
    esac
}

## Function to take in a target such as `x86_64-apple-darwin14` and spit out
## an SDK version such as "10.10"
target_to_darwin_sdk()
{
    case "$1" in
        *darwin14*)
            echo "10.10"
            ;;
        *darwin15*)
            echo "10.11"
            ;;
        *darwin16*)
            echo "10.12"
            ;;
    esac
}


## Function to download and install Linux kernel headers
install_kernel_headers()
{
    linux_url=http://www.kernel.org/pub/linux/kernel/v4.x/linux-${linux_version}.tar.xz

    # Download and install linux headers
    cd /src
    download_unpack.sh "${linux_url}"
    cd /src/linux-${linux_version}
    local ARCH="$(target_to_linux_arch ${target})"
    ${L32} make ARCH=${ARCH} mrproper
    ${L32} make ARCH=${ARCH} headers_check
    sudo -E ${L32} make INSTALL_HDR_PATH=/opt/${target}/${target} ARCH=${ARCH} V=0 headers_install

    # Cleanup
    cd /src
    sudo -E rm -rf linux-${linux_version}
}

# Helper to install a binutils cross-chain
install_binutils()
{
    # First argument is the version
    binutils_url=https://ftp.gnu.org/gnu/binutils/binutils-${binutils_version}.tar.bz2

    cd /src
    download_unpack.sh "${binutils_url}"

    # Build binutils!
    cd /src/binutils-${binutils_version}
    ${L32} ./configure \
        --prefix=/opt/${target} \
        --target=${target} \
        --disable-multilib \
        --disable-werror
    ${L32} make -j4

    # Install binutils
    sudo -E ${L32} make install

    # Cleanup
    cd /src
    sudo -E rm -rf binutils-${binutils_version}
}

## Helper to install stage1 of GCC (e.g. the C/C++ compilers, without libc)
install_gcc_stage1()
{
    # First argument is the version
    gcc_url=https://mirrors.kernel.org/gnu/gcc/gcc-${gcc_version}/gcc-${gcc_version}.tar.bz2

    # Download and unpack gcc
    cd /src
    download_unpack.sh "${gcc_url}"

    # target-specific GCC configuration flags
    GCC_CONF_ARGS=""

    # If we're building for Darwin, add on some extra configure arguments
    if [[ "${target}" == *apple* ]]; then
        sdk_version="$(target_to_darwin_sdk ${target})"
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --with-sysroot=/opt/${target}/MacOSX${sdk_version}.sdk"
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --with-ld=/opt/${target}/bin/${target}-ld"
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --with-as=/opt/${target}/bin/${target}-as"
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --enable-languages=c,c++,fortran,objc,obj-c++"
    fi

    if [[ "${target}" == *linux* ]]; then
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --enable-languages=c,c++,fortran"
    fi

    # Build gcc (stage 1)
    cd /src/gcc-${gcc_version}
    ${L32} contrib/download_prerequisites
    mkdir -p /src/gcc-${gcc_version}_build
    cd /src/gcc-${gcc_version}_build
    ${L32} /src/gcc-${gcc_version}/configure \
        --prefix=/opt/${target} \
        --target=${target} \
        --host=${MACHTYPE} \
        --build=${MACHTYPE} \
        --enable-threads=posix \
        --disable-multilib \
        --disable-werror \
        ${GCC_CONF_ARGS}

    ${L32} make -j4 all-gcc

    # Install gcc (stage 1)
    sudo -E ${L32} make install-gcc
}


# Helper to install libgcc
install_gcc_stage2()
{
    # Install libgcc (stage 2)
    cd /src/gcc-${gcc_version}_build
    ${L32} make -j4 all-target-libgcc
    sudo -E ${L32} make install-target-libgcc
}

# Helper to install the rest of GCC like gfortran, etc..., now that we've got
# an actual libc and compiler chain to compile with
install_gcc_stage3()
{
    # Install everything else like gfortran (stage 3)
    cd /src/gcc-${gcc_version}_build
    ${L32} make -j4
    sudo -E ${L32} make install

    # Cleanup
    cd /src
    sudo -E rm -rf gcc-${gcc_version}*
}

## Helper to install stage1 of glibc, e.g. the headers and crt1.o and friends
install_glibc_stage1()
{
    # First argument is the version
    glibc_url="http://gnu.mirrors.pair.com/gnu/glibc/glibc-${glibc_version}.tar.xz"
    cd /src
    download_unpack.sh "${glibc_url}"

    # patch glibc for ARM
    cd /src/glibc-${glibc_version}
    
    # patch glibc to keep around libgcc_s_resume on arm
    # ref: https://sourceware.org/ml/libc-alpha/2014-05/msg00573.html
    if [[ "${target}" == arm* ]] || [[ "${target}" == aarch* ]]; then 
        patch -p1 < /downloads/patches/glibc_arm_gcc_fix.patch
    fi

    # patch glibc's stupid gcc version check (we don't require this one, as if
    # it doesn't apply cleanly, it's probably fine)
    patch -p0 < /downloads/patches/glibc_gcc_version.patch || true

    # patch glibc's 32-bit assembly to withstand __i686 definition of newer GCC's
    # ref: http://comments.gmane.org/gmane.comp.lib.glibc.user/758
    if [[ "${target}" == i686* ]]; then
        patch -p1 < /downloads/patches/glibc_i686_asm.patch
    fi

    # build glibc
    mkdir -p /src/glibc-${glibc_version}_build
    cd /src/glibc-${glibc_version}_build
    CFLAGS="-O2 -U_FORTIFY_SOURCE -D__i686=__i686 -fno-stack-protector" ${L32} /src/glibc-${glibc_version}/configure \
        --prefix=/opt/${target}/${target} \
        --host=${target} \
        --target=${target} \
        --build=${MACHTYPE} \
        --with-headers=/opt/${target}/${target}/include \
        --disable-multilib \
        --with-binutils=/opt/${target}/bin \
        --disable-werror \
        libc_cv_forced_unwind=yes \
        libc_cv_c_cleanup=yes

    ${L32} make -j4 csu/subdir_lib
    sudo -E ${L32} make install-bootstrap-headers=yes install-headers

    # Manually copy over bits/stdio_lim.h
    sudo -E install bits/stdio_lim.h /opt/${target}/${target}/include/bits/

    # Manually copy over c runtime library object files
    sudo -E install csu/crt1.o csu/crti.o csu/crtn.o /opt/${target}/${target}/lib/

    # Create "stub" libc.so which is just empty
    sudo -E ${L32} ${target}-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/${target}/${target}/lib/libc.so
    sudo -E touch /opt/${target}/${target}/include/gnu/stubs.h
}

# Helper to install the rest of glibc
install_glibc_stage2()
{
    cd /src/glibc-${glibc_version}_build
    sudo -E chown buildworker:buildworker -R /src/glibc-${glibc_version}_build
    ${L32} make -j4
    sudo -E ${L32} make install

    # Cleanup
    cd /src
    sudo -E rm -rf glibc-${glibc_version}*
}


install_osx_sdk()
{
    # Download OSX SDK
    sdk_version="$(target_to_darwin_sdk ${target})"
    sdk_url="https://www.dropbox.com/s/yfbesd249w10lpc/MacOSX${sdk_version}.sdk.tar.xz"
    sudo mkdir -p /opt/${target}
    cd /opt/${target}
    sudo -E download_unpack.sh "${sdk_url}"
}

install_libtapi()
{
    # Download libtapi
    libtapi_url=https://github.com/tpoechtrager/apple-libtapi/archive/${libtapi_version}.tar.gz
    cd /src
    download_unpack.sh "${libtapi_url}"

    # Build and install libtapi
    cd /src/apple-libtapi-${libtapi_version}
    INSTALLPREFIX=/opt/${target} ${L32} ./build.sh
    sudo -E INSTALLPREFIX=/opt/${target} ${L32} ./install.sh

    # Cleanup
    cd /src
    sudo -E rm -rf apple-libtapi-${libtapi_version}
}

install_cctools()
{
    # Download cctools
    cctools_url=https://github.com/tpoechtrager/cctools-port/archive/${cctools_version}.tar.gz
    cd /src
    download_unpack.sh "${cctools_url}" 

    # Install cctools
    cd /src/cctools-port-${cctools_version}/cctools
    rm -f aclocal.m4
    ${L32} aclocal
    ${L32} libtoolize --force 
    ${L32} automake --add-missing --force
    ${L32} autoreconf
    ${L32} ./autogen.sh
    ${L32} ./configure \
        --prefix=/opt/${target} \
        --disable-clang-as \
        --with-libtapi=/opt/${target} \
        --target=${target}
    ${L32} make -j4
    sudo -E ${L32} make install

    # Cleanup
    cd /src
    sudo -E rm -rf cctools-port-${cctools_version}
}

install_dsymutil()
{
    dsymutil_url=https://github.com/tpoechtrager/llvm-dsymutil/archive/${dsymutil_version}.tar.gz
    cd /src
    download_unpack.sh "${dsymutil_url}"

    # Install dsymutil
    mkdir -p /src/llvm-dsymutil-${dsymutil_version}/build
    cd /src/llvm-dsymutil-${dsymutil_version}/build
    ${L32} cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DLLVM_ENABLE_ASSERTIONS=Off
    ${L32} make -f tools/dsymutil/Makefile -j4
    sudo -E cp bin/llvm-dsymutil /usr/local/bin/dsymutil

    # Cleanup
    cd /src
    sudo -E rm -rf llvm-dsymutil-${dsymutil_version}
}

install_mingw_stage1()
{
    mingw_url=https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/mingw-w64-v${mingw_version}.tar.bz2
    cd /src
    download_unpack.sh "${mingw_url}"

    # Install mingw headers
    cd /src/mingw-w64-v${mingw_version}/mingw-w64-headers
    ${L32} ./configure \
        --prefix=/opt/${target}/${target} \
        --enable-sdk=all \
        --enable-secure-api \
        --host=${target}
    
    sudo -E ${L32} make install
    # Arch's build has this line, I don't know why
    #rm -f /opt/${target}/include/pthread_{signal,time,unistd}.h
}

install_mingw_stage2()
{
    # Install crt
    mkdir -p /src/mingw-w64-v${mingw_version}-crt_build
    cd /src/mingw-w64-v${mingw_version}-crt_build
    ${L32} /src/mingw-w64-v${mingw_version}/mingw-w64-crt/configure \
        --prefix=/opt/${target}/${target} \
        --host=${target}

    ${L32} make -j4
    sudo ${L32} make install

    # Install winpthreads
    mkdir -p /src/mingw-w64-v${mingw_version}-winpthreads_build
    cd /src/mingw-w64-v${mingw_version}-winpthreads_build
    ${L32} /src/mingw-w64-v${mingw_version}/mingw-w64-libraries/winpthreads/configure \
        --prefix=/opt/${target}/${target} \
        --host=${target} \
        --enable-static \
        --enable-shared

    ${L32} make -j4
    sudo ${L32} make install
}



# Ensure that PATH is setup properly
export PATH=$PATH:/opt/${target}/bin

set -e
