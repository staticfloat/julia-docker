WORKDIR /src

## Install objconv
ARG objconv_version=2.47
ARG objconv_url=https://github.com/staticfloat/objconv/archive/v${objconv_version}.tar.gz

# Use download_unpack to download and unpack
RUN download_unpack.sh "${objconv_url}"

# Build the objconv sources!
WORKDIR /src/objconv-${objconv_version}
RUN ${L32} make

# Install objconv
USER root
RUN mv objconv /usr/local/bin/

# Now cleanup /src
WORKDIR /src
RUN rm -rf objconv-${objconv_version}*
