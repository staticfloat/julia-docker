INCLUDE crossbase-x64

# flex your arm musl
FROM shard_builder as shard_arm-linux-musleabihif
INCLUDE lib/crossbuild/version_defaults
ENV compiler_target="arm-linux-musleabihf"
INCLUDE lib/linux_musl_crosscompiler_install

