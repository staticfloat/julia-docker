INCLUDE crossbase-x64

# build gcc for i686.  Again use an especially old glibc version to maximize compatibility
FROM shard_builder as shard_i686-linux-gnu
INCLUDE lib/crossbuild/version_defaults
ARG glibc_version=2.19
ENV compiler_target="i686-linux-gnu"
INCLUDE lib/linux_glibc_crosscompiler_install

