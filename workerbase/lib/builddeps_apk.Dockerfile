# Tools that make it easy to get stuff done within the docker image
ARG NICE_TOOLS="vim curl gdb procps sudo"

# Tools to bootstrap our compiler chain that we will remove afterward
ARG TEMPORARY_DEPS="gcc g++"

# Tools that we need to build Julia and other deps that we are not going to
# build ourselves
ARG BUILD_DEPS="make musl-dev dpkg-dev m4 libressl-dev patch pkgconfig xz \
                zlib-dev curl-dev expat-dev gettext-dev wget zlib bzip2-dev autoconf \
                automake linux-headers libffi-dev"

# Install all these packages
RUN apk add ${NICE_TOOLS} ${TEMPORARY_DEPS} ${BUILD_DEPS}

# Create sha512sum wrapper
RUN rm /usr/bin/sha512sum
COPY fake_sha512sum.sh /usr/bin/sha512sum
