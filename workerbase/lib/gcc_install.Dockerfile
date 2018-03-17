## Install GCC
ARG gcc_version=7.3.0
ARG gcc_url=https://mirrors.kernel.org/gnu/gcc/gcc-${gcc_version}/gcc-${gcc_version}.tar.xz

# Download and unpack gcc
WORKDIR /src
RUN download_unpack.sh "${gcc_url}"

# Build gcc!
WORKDIR /src/gcc-${gcc_version}
RUN ${L32} contrib/download_prerequisites
RUN mkdir -p /src/gcc-${gcc_version}_build
WORKDIR /src/gcc-${gcc_version}_build
RUN ${L32} /src/gcc-${gcc_version}/configure \
    --prefix=/usr/local --enable-host-shared --enable-threads=posix \
    --with-system-zlib --enable-multilib \
    --enable-languages=c,c++,fortran,objc,obj-c++ ${gcc_configure_flags}
RUN ${L32} make -j4

# Install gcc
USER root
RUN ${L32} make install

# Symlink LTO plugin into binutils directory
RUN mkdir -p /usr/local/lib/bfd-plugins
RUN ln -sf $(find /usr/local/libexec/gcc/ -name liblto_plugin.so) /usr/local/lib/bfd-plugins/

# Setup environment variables so that GCC takes precedence from this point on
ENV PATH "/usr/local/bin:$PATH"

# Put our /lib and /lib64 directories into /etc/ld.so.conf.d so that they take precedence
RUN echo "/usr/local/lib"    > /etc/ld.so.conf.d/0_new_gcc.conf
RUN echo "/usr/local/lib64" >> /etc/ld.so.conf.d/0_new_gcc.conf
RUN ldconfig

# Add a `cc` symlink to gcc:
RUN ln -sf /usr/local/bin/gcc /usr/local/bin/cc

# Now cleanup /src
WORKDIR /src
RUN rm -rf gcc-${gcc_version}*
