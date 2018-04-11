INCLUDE crossbase-x64

# build for AArch64
FROM shard_builder as shard_aarch64-linux-gnu
INCLUDE lib/crossbuild/version_defaults
ENV compiler_target="aarch64-linux-gnu"
INCLUDE lib/linux_glibc_crosscompiler_install
