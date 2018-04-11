INCLUDE crossbase-x64

# Build for armv7l
FROM shard_builder as shard_arm-linux-gnueabihf
INCLUDE lib/crossbuild/version_defaults
ENV compiler_target="arm-linux-gnueabihf"
INCLUDE lib/linux_glibc_crosscompiler_install
