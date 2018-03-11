USER root
# Install libpng
RUN [[ -n "$(which yum 2>/dev/null)" ]] && yum install -y libpng-devel || true
RUN [[ -n "$(which apt-get 2>/dev/null)" ]] && apt-get install -y libpng-dev || true

USER buildworker
WORKDIR /src

ARG wine_version=2.0.3

RUN git clone https://github.com/wine-mirror/wine.git -b wine-${wine_version}
WORKDIR /src/wine
RUN ${L32} ./configure --without-x --without-freetype --enable-win64 --with-png
RUN ${L32} make -j3

USER root
RUN ${L32} make install
WORKDIR /src
RUN rm -rf wine

# Wine installs under `wine64`, but we still want it available via `wine`
RUN [[ -f /usr/local/bin/wine64 ]] && ln -s /usr/local/bin/wine64 /usr/local/bin/wine

