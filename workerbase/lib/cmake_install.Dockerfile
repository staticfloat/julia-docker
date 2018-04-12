## Install cmake into /usr/local
# Note that when you change `cmake_version`, you need to change the major version
# in the URL below, I would use ${cmake_version%.*} except that those fancy
# substitutions don't work in docker ARG rules.  :(
ARG cmake_version=3.11.0
ARG cmake_url=https://cmake.org/files/v3.11/cmake-${cmake_version}.tar.gz

WORKDIR /src

# Unfortunately, we have to pass `-k` to `curl` because cmake.org has weird SSL
# certificates, and old versions of `curl` can't deal with it.  :(
RUN EXTRA_CURL_FLAGS="-k" download_unpack.sh "${cmake_url}"

# Build the cmake sources!
WORKDIR /src/cmake-${cmake_version}
RUN ${L32} ./configure --prefix=/usr/local
RUN ${L32} make -j4

# Install as root
USER root
RUN ${L32} make install

# Patch cmake defaults
WORKDIR /
COPY patches/cmake_install.patch /tmp/
RUN patch -p0 < /tmp/cmake_install.patch; \
    rm -f /tmp/cmake_install.patch

# Now cleanup /src
WORKDIR /src
RUN rm -rf cmake-${cmake_version}
