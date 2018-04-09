## Install binutils
ARG binutils_version=2.29.1
ARG binutils_url=https://ftp.gnu.org/gnu/binutils/binutils-${binutils_version}.tar.xz

# All the targets EXCEPT darwin
ARG binutils_targets=x86_64-linux-gnu,i686-linux-gnu,aarch64-linux-gnu,arm-linux-gnueabihf,powerpc64le-linux-gnu,x86_64-w64-mingw32,i686-w64-mingw32,x86_64-unknown-freebsd

# Use download_unpack to download and unpack binutils and gcc
WORKDIR /src
RUN download_unpack.sh "${binutils_url}"

# Build binutils!  Because we're building for platforms including darwin, we need to
# first compile everything except ld for everything, then compile everything including
# ld for everything except darwin.  This is because binutils breaks when compiling for
# everything when that everything includes darwin because ld doesn't work on OSX.
WORKDIR /src/binutils-${binutils_version}
RUN ${L32} ./configure --prefix=/opt/super_binutils --enable-targets=${binutils_targets},x86_64-apple-darwin --disable-ld
RUN ${L32} make -j4

# Install binutils
RUN ${L32} make install

# Cleanup
WORKDIR /src
RUN rm -rf binutils-${binutils_version}


## Now do it again
WORKDIR /src
RUN download_unpack.sh "${binutils_url}"

# Install `ld` for everything except Darwin
WORKDIR /src/binutils-${binutils_version}
RUN ${L32} ./configure --prefix=/opt/super_binutils --enable-targets=${binutils_targets} --enable-ld
RUN ${L32} make -j4
RUN ${L32} make install-ld
WORKDIR /src
RUN rm -rf binutils-${binutils_version}

# Add this guy onto our PATH immediately
#ENV PATH=/opt/super_binutils/bin:$PATH
