FROM alpine:3.8





INCLUDE lib/alpha
INCLUDE lib/builddeps_apk

# musl does not support mudflap, or libsanitizer
# libmpx uses secure_getenv and struct _libc_fpstate not present in musl
# alpine musl provides libssp_nonshared.a, so we don't need libssp either
ARG gcc_configure_flags="--disable-libcilkrts --disable-libssp --disable-libmpx --disable-libmudflap --disable-libsanitizer --disable-multilib --build=x86_64-linux-musl --host=x86_64-linux-musl --target=x86_64-linux-musl"

INCLUDE lib/build_tools
INCLUDE lib/omega

