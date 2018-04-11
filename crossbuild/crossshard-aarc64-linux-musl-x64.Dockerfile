INCLUDE crossbase-x64

# AArch64 musl!
FROM shard_builder as shard_aarch64-linux-musl
INCLUDE lib/crossbuild/version_defaults
ENV compiler_target="aarch64-linux-musl"
INCLUDE lib/linux_musl_crosscompiler_install
