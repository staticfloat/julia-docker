INCLUDE crossbase-x64

# x86_64 FreeBSD build
FROM shard_builder as shard_x86_64-unknown-freebsd11.1
INCLUDE lib/crossbuild/version_defaults
ENV compiler_target="x86_64-unknown-freebsd11.1"
INCLUDE lib/freebsd_crosscompiler_install
