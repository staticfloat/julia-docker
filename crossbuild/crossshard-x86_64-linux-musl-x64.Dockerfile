INCLUDE crossbase-x64

# x86_64 musl
FROM shard_builder as shard_x86_64-linux-musl
INCLUDE lib/crossbuild/version_defaults
ARG compiler_target="x86_64-linux-musl"
INCLUDE lib/linux_musl_crosscompiler_install
