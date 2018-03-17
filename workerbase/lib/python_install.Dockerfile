## Install python
ARG python_version=2.7.14
ARG python_url=https://www.python.org/ftp/python/${python_version}/Python-${python_version}.tar.xz
ARG pip_url=https://bootstrap.pypa.io/get-pip.py
WORKDIR /src

# Use download_unpack to download and unpack python
RUN download_unpack.sh "${python_url}"

# Build the python sources!
WORKDIR /src/Python-${python_version}
RUN ${L32} ./configure --prefix=/usr/local
RUN ${L32} make -j4

# Install python
USER root
RUN ${L32} make install

# Install pip and install virtualenv (all as root, of course)
RUN curl -q -# -L "${pip_url}" -o get-pip.py
RUN python ./get-pip.py
RUN pip install virtualenv

# Now cleanup /src
WORKDIR /src
RUN rm -rf Python-${python_version}
RUN rm -f get-pip.py
