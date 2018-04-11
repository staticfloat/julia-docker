FROM staticfloat/julia_crossbase:x64

# Copy all our built shards into one ginormous image
COPY --from=staticfloat/julia_crossshard-x86_64-linux-gnu:x64 /opt/x86_64-linux-gnu /opt/x86_64-linux-gnu
COPY --from=staticfloat/julia_crossshard-i686-linux-gnu:x64 /opt/i686-linux-gnu /opt/i686-linux-gnu
COPY --from=staticfloat/julia_crossshard-aarch64-linux-gnu:x64 /opt/aarch64-linux-gnu /opt/aarch64-linux-gnu
COPY --from=staticfloat/julia_crossshard-arm-linux-gnueabihf:x64 /opt/arm-linux-gnueabihf /opt/arm-linux-gnueabihf
COPY --from=staticfloat/julia_crossshard-powerpc64le-linux-gnu:x64 /opt/powerpc64le-linux-gnu /opt/powerpc64le-linux-gnu
COPY --from=staticfloat/julia_crossshard-x86_64-apple-darwin14:x64 /opt/x86_64-apple-darwin14 /opt/x86_64-apple-darwin14
COPY --from=staticfloat/julia_crossshard-x86_64-w64-mingw32:x64 /opt/x86_64-w64-mingw32 /opt/x86_64-w64-mingw32
COPY --from=staticfloat/julia_crossshard-i686-w64-mingw32:x64 /opt/i686-w64-mingw32 /opt/i686-w64-mingw32
COPY --from=staticfloat/julia_crossshard-x86_64-linux-musl:x64 /opt/x86_64-linux-musl /opt/x86_64-linux-musl
COPY --from=staticfloat/julia_crossshard-i686-linux-musl:x64 /opt/i686-linux-musl /opt/i686-linux-musl
COPY --from=staticfloat/julia_crossshard-arm-linux-musleabihf:x64 /opt/arm-linux-musleabihf /opt/arm-linux-musleabihf
COPY --from=staticfloat/julia_crossshard-aarch64-linux-musl:x64 /opt/aarch64-linux-musl /opt/aarch64-linux-musl
COPY --from=staticfloat/julia_crossshard-x86_64-unknown-freebsd:x64 /opt/x86_64-unknown-freebsd /opt/x86_64-unknown-freebsd

# Install sandbox, using x86_64-linux-gnu compiler.  We do this at the end so that if we need
# to iterate on this particular piece, we don't have to rebuild the entire image.
ADD https://raw.githubusercontent.com/JuliaPackaging/BinaryBuilder.jl/master/deps/sandbox.c /sandbox.c
RUN /opt/x86_64-linux-gnu/bin/gcc -std=c99 -o /sandbox /sandbox.c; rm -f /sandbox.c

# Cleanup downloads and build.sh
RUN rm -rf /downloads /build.sh

# Set default workdir
WORKDIR /workspace
CMD ["/bin/bash"]
