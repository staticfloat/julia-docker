FROM python:2

RUN mkdir -p /buildbot
WORKDIR /buildbot

ARG buildbot_branch=master
ARG db_user
ARG db_password

# First, grab builddeps and buildbot itself
RUN apt update && apt install -y git libsqlite3-dev libssl-dev
RUN pip install --upgrade pip
RUN pip install psycopg2 buildbot[tls] buildbot-www buildbot-waterfall-view \
                buildbot-console-view urllib3[secure] requests ipython \
                buildbot_profiler

# Clone/configure buildbot (the ADD command is to rebuild the rest of the image
# from here on out without caching in case the remote repo has changed)
ADD https://api.github.com/repos/staticfloat/julia-buildbot/git/refs/heads/${buildbot_branch} /buildbot_version.json
RUN git clone -b ${buildbot_branch} https://github.com/staticfloat/julia-buildbot.git .
RUN buildbot create-master master

# Install secret files (Note, you must have unlocked this repo, as these are all
# encrypted, and failing to do so will give strange unicode errors!)
COPY buildbot_secret.py /buildbot/master
RUN echo "db_user=\"${db_user}\"" >> /buildbot/master/buildbot_secret.py
RUN echo "db_password=\"${db_password}\"" >> /buildbot/master/buildbot_secret.py
COPY julia.gpg /root/
COPY awssecret /root/.awssecret
RUN mkdir -p /root/.gnupg
RUN gpg --import /root/julia.gpg
COPY authorized_keys /buildbot/master
COPY ssh_host_rsa_key /etc/ssh/
COPY ssh_host_rsa_key.pub /etc/ssh/
COPY try_thrice /root/bin/try_thrice

# Install entrypoint and run it!
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/sh"]
CMD ["/entrypoint.sh"]
