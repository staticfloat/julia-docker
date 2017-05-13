buildworker_name="$1"

if [[ -z "$buildworker_name" ]]; then
    echo "Usage: $0 <buildworker_name>" >&2
    exit 1
fi

# "When this message has finished, it will self-destruct"
# This gives us parameters like the password to login to the buildbot, etc...
cd "$(dirname "${BASH_SOURCE[0]}")"
source secret.sh
rm -f secret.sh

if [[ -z "$buildbot_password" ]]; then
    echo "ERROR: Didn't get a buildbot_password from secret.sh.  Does it exist?" >&2
    exit 1
fi

vagrant_sudo()
{
    # If we're on OSX, actually sudo, if we're on windows, ignore that
    if [[ "$(uname)" == "Darwin" ]]; then
        sudo -H -u vagrant "$@"
    else
        "$@"
    fi
}


function install_brew()
{
    echo "Installing brew..."
    # If brew is already installed, then back out
    if [[ -n "$(which brew 2>/dev/null)" ]]; then
        return
    fi

    # Install brew, don't let it ask questions, add it to the currently running PATH
    brew_url="https://raw.githubusercontent.com/Homebrew/install/master/install"
    echo "Downloading via ruby..."
    vagrant_sudo ruby -e "$(curl -fsSL "$brew_url")" </dev/null
    export PATH="$PATH:/usr/local/bin:/usr/local/sbin"

    # Install git and python, especially so we can get `pip`
    vagrant_sudo brew install git python
}

function install_buildbot()
{
    # If it already exists, then back out
    if [[ -d "~/worker" ]]; then
        return
    fi

    # pip it in as root, then configure it as vagrant
    pip install buildbot-worker
    vagrant_sudo bash <<EOF
cd ~
buildbot-worker create-worker --keepalive=100 --umask 022 worker $buildbot_server:$buildbot_port $buildworker_name $buildbot_password
echo "Elliot Saba <staticfloat@gmail.com>" > worker/info/admin
echo "Julia $buildworker_name buildworker" > worker/info/host
EOF
}

run_buildbot()
{
    # As vagrant, restart the worker
    vagrant_sudo bash -c "cd ~; buildbot-worker restart worker"
}

# Install things, then run the buildbot
if [[ "$(uname)" == "Darwin" ]]; then
    install_brew
fi
install_buildbot
run_buildbot
