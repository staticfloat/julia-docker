FROM telegraf

RUN apt update && apt install -y lm-sensors
COPY telegraf.conf /etc/telegraf/telegraf.conf
