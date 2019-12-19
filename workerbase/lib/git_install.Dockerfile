## Install git
ARG git_version=2.24.1
ARG git_url=https://github.com/git/git/archive/v${git_version}.tar.gz
WORKDIR /src

# Use download_unpack to download and unpack git
RUN download_unpack.sh "${git_url}" /downloads/git-${git_version}.tar.gz
WORKDIR /src/git-${git_version}
RUN ${L32} make NO_GETTEXT=1 NO_REGEX=YesPlease prefix=/usr/local all -j4

# Install git
USER root
RUN ${L32} make NO_GETTEXT=1 NO_REGEX=YesPlease prefix=/usr/local install

# cleanup /src
WORKDIR /src
RUN rm -rf git-${git_version}
