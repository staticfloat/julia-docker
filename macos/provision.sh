#!/bin/bash

if [[ -z "${BUILDBOT_PASSWORD}" ]]; then
    echo "Must define BUILDBOT_PASSWORD" >&2
    exit 1
fi

brew install tmux bash ccache reattach-to-user-namespace gcc@7

# We want `gfortran` to mean `gfortran-7`
ln -s $(which gfortran-7) /usr/local/bin/gfortran

# Install buildbot-worker
pip3 install --user buildbot-worker
export PATH=$PATH:$(echo ~/Library/Python/*/bin)
mkdir ~/buildbot

# Install buildbot worker directories
ARCH="x86_64"
if [[ $(uname -m) == "arm64" ]]; then
    ARCH="aarch64"
fi

buildbot-worker create-worker --keepalive=100 --umask 0o022 worker build.julialang.org:9989 macos-${ARCH}-$(hostname -s) ${BUILDBOT_PASSWORD}
buildbot-worker create-worker --keepalive=100 --umask 0o022 worker-tabularasa build.julialang.org:9989 tabularasa_macos-${ARCH}-$(hostname -s) ${BUILDBOT_PASSWORD}
echo "Elliot Saba <staticfloat@gmail.com>" > worker/info/admin
echo "Elliot Saba <staticfloat@gmail.com>" > worker-tabularasa/info/admin
echo "Julia $(hostname -s) buildworker" > worker/info/host
echo "Julia tabularasa $(hostname -s) buildworker" > worker-tabularasa/info/host

# Add startup scripts for them all
startup_script --name buildbot --exe $(which buildbot-worker) --chdir ~/buildbot --args "restart --nodaemon worker" --env "HOME=${HOME}"
startup_script --name buildbot-tabularasa --exe $(which buildbot-worker) --chdir ~/buildbot --args "restart --nodaemon worker-tabularasa" --env "HOME=${HOME}"

# Start the services right meow :3
sudo launchctl load -w /Library/LaunchDaemons/buildbot.plist
sudo launchctl load -w /Library/LaunchDaemons/buildbot-tabularasa.plist

echo "Okay done!  Next steps:"
echo " * Turn on auto-login, to avoid pbcopy/pbpaste errors"
echo " * Copy over xcode.keychain and unlock_keychain.sh"
