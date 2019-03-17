## Download and install needed build dependencies for x86_64 yum-based systems
USER root
RUN ${L32} yum update -y

# Tools that make it easy to get stuff done within the docker image
ARG NICE_TOOLS="vim curl gdb net-tools which sudo time"

# Tools to bootstrap our compiler chain that we will remove afterward
ARG TEMPORARY_DEPS="gcc gcc-c++"

# Tools that we need to build Julia and other deps that we are not going to
# build ourselves
ARG BUILD_DEPS="make m4 openssl openssl-devel patch pkg-config curl-devel \
               expat-devel gettext-devel perl-devel wget bzip2 tar \ 
               zlib-devel bzip2-devel xz rpmdevtools autoconf automake \
               glibc-devel.i686 glibc-devel"

# Install all these packages
RUN ${L32} yum install -y ${NICE_TOOLS} ${TEMPORARY_DEPS} ${BUILD_DEPS}

# Fixup sudo problems
RUN ${L32} sed -i.bak -e 's/Defaults[[:space:]]*env_reset//g' /etc/sudoers
RUN ${L32} sed -i.bak -e 's/Defaults[[:space:]]*secure_path[[:space:]]*=.*//g' /etc/sudoers
