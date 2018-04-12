INCLUDE crossbase-x64

# musl on i686
FROM shard_builder as shard_i686-linux-musl
INCLUDE lib/crossbuild/version_defaults
ENV compiler_target="i686-linux-musl"
INCLUDE lib/linux_musl_crosscompiler_install
