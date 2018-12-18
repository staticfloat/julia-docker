## Download and install needed build dependencies for x86_64 apt-based systems
USER root
RUN ${L32} apt-get update

# Tools that make it easy to get stuff done within the docker image
ARG NICE_TOOLS="vim curl gdb procps sudo time"

# Tools to bootstrap our compiler chain that we will remove afterward
ARG TEMPORARY_DEPS="gcc g++"

# Tools that we need to build Julia and other deps that we are not going to
# build ourselves
ARG BUILD_DEPS="make libc6-dev dpkg-dev m4 libssl-dev patch pkg-config \
               libcurl4-openssl-dev libexpat1-dev gettext wget zlib1g-dev \ 
               libbz2-dev autoconf automake"

# Install all these packages
RUN ${L32} apt-get install -y ${NICE_TOOLS} ${TEMPORARY_DEPS} ${BUILD_DEPS}

# I hate that on 32-bit ubuntu, libc6-dev is i386 and libc6-dev-i386 doesn't
# exist. Consistency Conshmistency, amirite?  It's too much work to properly
# identify which version we're running on, so instead just allow this to fail.
RUN ${L32} apt-get install -y libc6-dev-i386 || echo "Stupid Ubuntu".
