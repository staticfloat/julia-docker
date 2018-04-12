ARG glibc_url="http://mirrors.peers.community/mirrors/gnu/glibc/glibc-${glibc_version}.tar.xz"

WORKDIR /src
RUN download_unpack.sh "${glibc_url}"

# patch glibc for ARM
WORKDIR /src/glibc-${glibc_version}

# patch glibc to keep around libgcc_s_resume on arm
# ref: https://sourceware.org/ml/libc-alpha/2014-05/msg00573.html
COPY patches/glibc_arm_gcc_fix.patch /tmp/
RUN if [[ "${compiler_target}" == arm* ]] || [[ "${compiler_target}" == aarch* ]]; then \
        patch -p1 < /tmp/glibc_arm_gcc_fix.patch; \
    fi; \
    rm -f /tmp/glibc_arm_gcc_fix.patch

# patch glibc's stupid gcc version check (we don't require this one, as if
# it doesn't apply cleanly, it's probably fine)
COPY patches/glibc_gcc_version.patch /tmp/
RUN patch -p0 < /tmp/glibc_gcc_version.patch || true; \
    rm -f /tmp/glibc_gcc_version.patch

# patch glibc's 32-bit assembly to withstand __i686 definition of newer GCC's
# ref: http://comments.gmane.org/gmane.comp.lib.glibc.user/758
COPY patches/glibc_i686_asm.patch /tmp/
RUN if [[ "${compiler_target}" == i686* ]]; then \
        patch -p1 < /tmp/glibc_i686_asm.patch; \
    fi; \
    rm -f /tmp/glibc_i686_asm.patch

# Patch glibc's sunrpc cross generator to work with musl
# See https://sourceware.org/bugzilla/show_bug.cgi?id=21604
COPY patches/glibc-sunrpc.patch /tmp/
RUN patch -p0 < /tmp/glibc-sunrpc.patch; \
    rm -f /tmp/glibc-sunrpc.patch

# patch for building old glibc on newer binutils
# These patches don't apply on those versions of glibc where they
# are not needed, but that's ok.
COPY patches/glibc_nocommon.patch /tmp/
RUN patch -p0 < /tmp/glibc_nocommon.patch || true; \
    rm -f /tmp/glibc_nocommon.patch
COPY patches/glibc_regexp_nocommon.patch /tmp/
RUN patch -p0 < /tmp/glibc_regexp_nocommon.patch || true; \
    rm -f /tmp/glibc_regexp_nocommon.patch

# build glibc
WORKDIR /src/glibc-${glibc_version}_build
RUN source /build.sh; \
    /src/glibc-${glibc_version}/configure \
        --prefix=/usr \
        --host=${compiler_target} \
        --with-headers="$(get_sysroot)/usr/include" \
        --with-binutils=/opt/${compiler_target}/bin \
        --disable-multilib \
        --disable-werror \
        libc_cv_forced_unwind=yes \
        libc_cv_c_cleanup=yes
RUN chown $(id -u):$(id -g) -R /src/glibc-${glibc_version}_build
RUN make -j$(nproc)
RUN source /build.sh; make install install_root="$(get_sysroot)"

# GCC won't build (crti.o: no such file or directory) unless these directories exist.
# They can be empty though.
RUN source /build.sh; mkdir -p $(get_sysroot)/{lib,usr/lib}

# Cleanup
WORKDIR /src
RUN rm -rf glibc-${glibc_version}*
