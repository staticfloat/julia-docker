INCLUDE crossbase-x64

# build for mac64
FROM shard_builder as shard_x86_64-apple-darwin14
INCLUDE lib/crossbuild/version_defaults
ENV compiler_target="x86_64-apple-darwin14"
INCLUDE lib/osx_crosscompiler_install
