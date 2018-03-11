FROM ivochkin/ubuntu-i386:xenial

# This enables putting `linux32` before commands like `./configure` and `make`
ARG L32=linux32

INCLUDE lib/alpha
INCLUDE lib/builddeps_apt
INCLUDE lib/build_tools
INCLUDE lib/omega
