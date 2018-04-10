INCLUDE crossbase-x64

# x86_64 FreeBSD build
FROM shard_builder as shard_x86_64-unknown-freebsd
INCLUDE lib/crossbuild/version_defaults
ARG compiler_target="x86_64-unknown-freebsd"
INCLUDE lib/freebsd_crosscompiler_install
