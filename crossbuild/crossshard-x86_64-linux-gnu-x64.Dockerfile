INCLUDE crossbase-x64

# build gcc for x86_64.  Use an especially old glibc version to maximize compatibility
FROM shard_builder as shard_x86_64-linux-gnu
INCLUDE lib/crossbuild/version_defaults
ARG glibc_version=2.12.2
ENV compiler_target="x86_64-linux-gnu"
INCLUDE lib/linux_glibc_crosscompiler_install
