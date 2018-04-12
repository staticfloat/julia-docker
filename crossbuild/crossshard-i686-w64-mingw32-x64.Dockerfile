INCLUDE crossbase-x64

# Build for win32.  We use gcc 6.X, so that we stay with the old
# gfortran.3 ABI, not gfortran.4, as that doesn't work with our Julia builds.
FROM shard_builder as shard_i686-w64-mingw32
INCLUDE lib/crossbuild/version_defaults
ENV compiler_target="i686-w64-mingw32"
ARG gcc_version="6.4.0"
INCLUDE lib/win_crosscompiler_install
