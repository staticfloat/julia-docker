FROM centos:6.9




INCLUDE lib/alpha
INCLUDE lib/builddeps_yum
INCLUDE lib/build_tools

COPY build_crosscompiler.sh /build.sh
COPY patches /downloads/patches

# Also install windows cross-compilers
ENV target="x86_64-w64-mingw32"
USER buildworker
INCLUDE lib/win_crosscompiler_install

# Install Wine
USER root
RUN yum install -y libstdc++.i686 flex bison
USER buildworker
INCLUDE lib/wine_install
ENV WINEARCH=win64

INCLUDE lib/omega
