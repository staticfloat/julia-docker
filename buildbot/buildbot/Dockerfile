FROM python:2

RUN mkdir -p /buildbot
WORKDIR /buildbot

ARG buildbot_branch
ARG db_user
ARG db_password
ARG GITHUB_OAUTH_CLIENT_ID
ARG GITHUB_OAUTH_CLIENT_SECRET

# First, grab builddeps and buildbot itself
RUN apt update && apt install -y git libsqlite3-dev libssl-dev
RUN pip install --upgrade pip
RUN pip install psycopg2 buildbot[tls,bundle] urllib3[secure] requests ipython \
                buildbot_profiler docker awscli txrequests git+https://github.com/iblis17/buildbot-freebsd.git

# Clone/configure buildbot configuration
# the ADD command is to rebuild the rest of the image from here on out
# without caching in case the remote repo has changed)
ADD https://api.github.com/repos/staticfloat/julia-buildbot/git/refs/heads/${buildbot_branch} /julia-buildbot_version.json
RUN git clone -b ${buildbot_branch} https://github.com/staticfloat/julia-buildbot.git .
RUN buildbot create-master master

# Install secret files (Note, you must have unlocked this repo, as these are all
# encrypted, and failing to do so will give strange unicode errors!)
COPY buildbot_secret.py /buildbot/master
RUN echo "db_user=\"${db_user}\"" >> /buildbot/master/buildbot_secret.py
RUN echo "db_password=\"${db_password}\"" >> /buildbot/master/buildbot_secret.py
RUN echo "GITHUB_OAUTH_CLIENT_ID='${GITHUB_OAUTH_CLIENT_ID}'" >> /buildbot/master/buildbot_secret.py
RUN echo "GITHUB_OAUTH_CLIENT_SECRET='${GITHUB_OAUTH_CLIENT_SECRET}'" >> /buildbot/master/buildbot_secret.py
RUN echo "FREEBSDCI_OAUTH_TOKEN='${FREEBSDCI_OAUTH_TOKEN}'" >> /buildbot/master/buildbot_secret.py
COPY julia.gpg /root/
RUN mkdir -p /root/.aws
COPY aws_credentials /root/.aws/credentials
RUN chmod 0600 /root/.aws/credentials
RUN mkdir -p /root/.gnupg
RUN gpg --batch --import /root/julia.gpg
COPY try_thrice /root/bin/try_thrice

# Install entrypoint and run it!
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/sh"]
CMD ["/entrypoint.sh"]
