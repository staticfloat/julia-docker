INCLUDE crossbase-x64

# build gcc for ppc64le (we need a more recent glibc here as well)
# We require at least version 2.22 for the fixes to assembler problems:
# https://sourceware.org/bugzilla/show_bug.cgi?id=18116
# We require at least version 2.24 for the fixes to memset.S:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=843691
FROM shard_builder as shard_powerpc64le-linux-gnu
INCLUDE lib/crossbuild/version_defaults
ENV compiler_target="powerpc64le-linux-gnu"
ARG glibc_version=2.25
INCLUDE lib/linux_glibc_crosscompiler_install
