USER root
WORKDIR /src

ARG wine_version=3.1

RUN git clone https://github.com/wine-mirror/wine.git -b wine-${wine_version}
WORKDIR /src/wine

# Install some dependencies
RUN [[ -n "$(which yum 2>/dev/null)" ]] && yum install -y libpng-devel libjpeg-dev libxslt-dev libgnutls-dev || true
RUN [[ -n "$(which apt-get 2>/dev/null)" ]] && apt-get install -y libpng-dev libjpeg-dev libxslt-dev libgnutls-dev || true
RUN [[ -n "$(which apk 2>/dev/null)" ]] && apk add libpng-dev libjpeg-turbo-dev libxslt-dev gnutls-dev || true

# Patch -no-pie into LDFLAGS 
COPY patches/wine_nopie.patch /tmp/
RUN patch -p1 < /tmp/wine_nopie.patch; \
    rm -f /tmp/wine_nopie.patch

# First, build wine64
RUN mkdir /src/wine64_build
WORKDIR /src/wine64_build
RUN ${L32} /src/wine/configure --without-x --without-freetype --enable-win64
RUN ${L32} make -j3

# Next, build wine32
RUN mkdir /src/wine32_build
WORKDIR /src/wine32_build
RUN ${L32} /src/wine/configure --without-x --without-freetype --with-wine64=/src/wine64_build
RUN ${L32} make -j3

# Now install wine32, and THEN wine64... le sigh...
USER root
WORKDIR /src/wine32_build
RUN ${L32} make install
WORKDIR /src/wine64_build
RUN ${L32} make install

# cleanup
WORKDIR /src
RUN rm -rf wine*

