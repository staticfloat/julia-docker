FROM python:3

RUN mkdir -p /buildbot
WORKDIR /buildbot

# First, grab builddeps and buildbot itself
RUN apt update && apt install -y git libsqlite3-dev libssl-dev
RUN pip install --upgrade pip
RUN pip install psycopg2 requests ipython docker awscli txrequests urllib3[secure] mock buildbot[tls,bundle]
RUN git clone https://github.com/iblis17/buildbot -b ib/reporter-verbose /tmp/buildbot_build
RUN pip install /tmp/buildbot_build/master
RUN rm -rf /tmp/buildbot_build
RUN pip install buildbot_profiler git+https://github.com/iblis17/buildbot-freebsd.git

# Clone/configure buildbot configuration
# the ADD command is to rebuild the rest of the image from here on out
# without caching in case the remote repo has changed)
ARG BUILDBOT_BRANCH
ADD https://api.github.com/repos/staticfloat/julia-buildbot/git/refs/heads/${BUILDBOT_BRANCH} /julia-buildbot_version.json
RUN git clone -b ${BUILDBOT_BRANCH} https://github.com/staticfloat/julia-buildbot.git .
RUN buildbot create-master master

# Install secret files (Note, you must have unlocked this repo, as these are all
# encrypted, and failing to do so will give strange unicode errors!)
ARG db_user
ARG db_password
ARG GITHUB_OAUTH_CLIENT_ID
ARG GITHUB_OAUTH_CLIENT_SECRET
ARG GITHUB_STATUS_OAUTH_TOKEN
ARG FREEBSDCI_OAUTH_TOKEN
ARG FQDN
COPY buildbot_secret.py /buildbot/master
RUN echo "db_user='${db_user}'" >> /buildbot/master/buildbot_secret.py
RUN echo "db_password='${db_password}'" >> /buildbot/master/buildbot_secret.py
RUN echo "FQDN='${FQDN}'" >> /buildbot/master/buildbot_secret.py
RUN echo "BUILDBOT_BRANCH='${BUILDBOT_BRANCH}'" >> /buildbot/master/buildbot_secret.py
RUN echo "GITHUB_OAUTH_CLIENT_ID='${GITHUB_OAUTH_CLIENT_ID}'" >> /buildbot/master/buildbot_secret.py
RUN echo "GITHUB_OAUTH_CLIENT_SECRET='${GITHUB_OAUTH_CLIENT_SECRET}'" >> /buildbot/master/buildbot_secret.py
RUN echo "GITHUB_STATUS_OAUTH_TOKEN='${GITHUB_STATUS_OAUTH_TOKEN}'" >> /buildbot/master/buildbot_secret.py
RUN echo "FREEBSDCI_OAUTH_TOKEN='${FREEBSDCI_OAUTH_TOKEN}'" >> /buildbot/master/buildbot_secret.py
RUN echo "MACOS_CODESIGN_IDENTITY='${MACOS_CODESIGN_IDENTITY}'" >> /buildbot/master/buildbot_secret.py
COPY julia.gpg sign_tarball.sh /root/
RUN chmod +x /root/sign_tarball.sh
RUN mkdir -p /root/.aws
COPY aws_credentials /root/.aws/credentials
RUN chmod 0600 /root/.aws/credentials
RUN mkdir -p /root/.gnupg
RUN gpg --batch --import /root/julia.gpg
COPY try_thrice /root/bin/try_thrice

# GPG needs a tty, apparently
ENV GPG_TTY=/dev/pts/0

# Install entrypoint and run it!
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/sh"]
CMD ["/entrypoint.sh"]
