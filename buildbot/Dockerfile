FROM nginx

RUN mkdir -p /buildbot
WORKDIR /buildbot

# First, grab builddeps and buildbot itself
RUN apt update && apt install -y git python python-dev python-pip libsqlite3-dev bzr devscripts libssl-dev
RUN pip install --upgrade pip
RUN pip install buildbot[tls] buildbot-www buildbot-waterfall-view \
                buildbot-console-view urllib3[secure] requests ipython

# Clone/configure buildbot
RUN git clone https://github.com/staticfloat/julia-buildbot.git .
RUN buildbot create-master master

# Install secret files (Note, you must have unlocked this repo, as these are all
# encrypted, and failing to do so will give strange unicode errors!)
COPY buildbot_secret.py /buildbot/
COPY julia.key /root/
COPY awssecret /root/.awssecret
RUN mkdir -p /root/.gnupg
