#!/bin/bash
# Setup keychain on OSX buildbot for code signing

if [[ "$USER" != "vagrant" ]]; then
    echo "Re-running self as vagrant"
    sudo -H -u vagrant "$0"
    exit $?
fi

# Create the keychain with no password, and immediately unlock it
security -v create-keychain -p "" ~/julia.keychain
security -v unlock-keychain -p "" ~/julia.keychain

# Set the settings with no flags, which sets it to never lock again
security -v set-keychain-settings ~/julia.keychain

# Set it to be the default keychain
security -v default-keychain -s ~/julia.keychain

# Import our codesigning key
security -v import /tmp/julia.p12 -k ~/julia.keychain -T /usr/bin/codesign -P "a9cbc036ac62dc5ba5200416ca7b40a2f9aa59ea"

# Generate unlock_keychain.sh
cat >~/unlock_keychain.sh <<EOF
security unlock-keychain -p "" ~/julia.keychain
security show-keychain-info ~/julia.keychain
security find-identity ~/julia.keychain
EOF
chmod +x ~/unlock_keychain.sh

rm -f /tmp/julia.p12 "$0"
