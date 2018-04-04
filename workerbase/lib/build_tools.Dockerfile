# Download and install `tar` because some machines have it too old and don't
# know what `.xz` files are.  Build it first so that we can use it to extract
# our other tools.  Yes, this means this is the only tool that's not built with
# our new GCC, but that's okay.
USER buildworker
INCLUDE tar_install

# Download and install `gcc` because we want only the latest in cutting-edge
# compiler technology, and also because LLVM is a needy little piece of software
USER buildworker
INCLUDE binutils_install
USER buildworker
INCLUDE gcc_install

# Download and install `libtool` based off of our GCC version
USER buildworker
INCLUDE libtool_install

# Download and install `patchelf` because he's a really standup guy
USER buildworker
INCLUDE patchelf_install

# Download and install `git` because some of the distributions we build on are
# old enough that `git` isn't even installable from the default distributions
USER buildworker
INCLUDE git_install

# Download and install `cmake` because LLVM again.  Whiner.
USER buildworker
INCLUDE cmake_install

# Download and install `python` because buildbot doesn't like ancient versions
USER buildworker
INCLUDE python_install

# Download and install `ccache` to speed up compilation
USER buildworker
INCLUDE ccache_install

# Download and install `docker`, because we often want to build our own images again
USER buildworker
INCLUDE docker_install
