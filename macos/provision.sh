#!/bin/bash

if [[ -z "${BUILDBOT_PASSWORD}" ]]; then
    echo "Must define BUILDBOT_PASSWORD" >&2
    exit 1
fi

brew install tmux bash

pip3 install --user buildbot-worker
export PATH=$PATH:$(echo ~/Library/Python/*/bin)
mkdir ~/buildbot

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

startup_script --name buildbot --exe $(which buildbot-worker) --chdir ~/buildbot --args "restart --nodaemon worker"
startup_script --name buildbot-tabularasa --exe $(which buildbot-worker) --chdir ~/buildbot --args "restart --nodaemon worker-tabularasa"

sudo launchctl load -w /Library/LaunchDaemons/buildbot.plist
sudo launchctl load -w /Library/LaunchDaemons/buildbot-tabularasa.plist
