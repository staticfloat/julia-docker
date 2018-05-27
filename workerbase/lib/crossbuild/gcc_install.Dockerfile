WORKDIR /src/gcc-${gcc_version}_build

# target-specific GCC configuration flags.  For example,
# musl does not support mudflap, or libsanitizer
# libmpx uses secure_getenv and struct _libc_fpstate not present in musl
# alpine musl provides libssp_nonshared.a, so we don't need libssp either
RUN source /build.sh; \
    GCC_CONF_ARGS=""; \
    if [[ "${compiler_target}" == *apple* ]]; then \
        sdk_version="$(target_to_darwin_sdk ${compiler_target})"; \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --with-ld=/opt/${compiler_target}/bin/${compiler_target}-ld"; \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --with-as=/opt/${compiler_target}/bin/${compiler_target}-as"; \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --enable-languages=c,c++,fortran,objc,obj-c++"; \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --with-sysroot=$(get_sysroot)"; \
    elif [[ "${compiler_target}" == *linux* ]]; then \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --enable-languages=c,c++,fortran"; \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --with-sysroot=$(get_sysroot)"; \
    elif [[ "${compiler_target}" == *freebsd* ]]; then \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --enable-languages=fortran"; \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --with-sysroot=$(get_sysroot)"; \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --disable-default-pie"; \
    fi; \
    if [[ "${compiler_target}" == arm*hf ]]; then \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --with-float=hard --with-arch=armv7-a --with-fpu=vfpv3-d16"; \
    fi; \
    if [[ "${compiler_target}" == *musl* ]]; then \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --disable-libssp --disable-libmpx"; \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --disable-libmudflap --disable-libsanitizer"; \
        GCC_CONF_ARGS="${GCC_CONF_ARGS} --disable-symvers"; \
        export libat_cv_have_ifunc=no; \
    fi; \
    /src/gcc-${gcc_version}/configure \
        --prefix=/opt/${compiler_target} \
        --target=${compiler_target} \
        --host=${MACHTYPE} \
        --build=${MACHTYPE} \
        --disable-multilib \
        --disable-werror \
        --enable-host-shared \
        --enable-threads=posix \
        ${GCC_CONF_ARGS}

RUN if [[ "${compiler_target}" == *freebsd* ]]; then \
        export ac_cv_have_decl___builtin_ffs=yes; \
    fi; \
    make -j$(nproc)
RUN make install

# Because this always writes out .texi files, we have to chown them back.  >:(
RUN chown $(id -u):$(id -g) -R .

WORKDIR /src
RUN rm -rf gcc-${gcc_version}*

# Finally, create a bunch of symlinks stripping out the target so that
# things like `gcc` "just work", as long as we've got our path set properly
# We don't worry about failure to create these symlinks, as sometimes there are files
# named ridiculous things like ${compiler_target}-${compiler_target}-foo, which screws this up
RUN source /build.sh; \
    for f in /opt/${compiler_target}/bin/${compiler_target}-*; do \
        fbase=$(basename $f); \
        ln -s $f /opt/${compiler_target}/bin/${fbase#${compiler_target}-} || true; \
    done
