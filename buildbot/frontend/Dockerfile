FROM jonasal/nginx-certbot

ARG fqdn

# Deploy nginx configuration, templated properly for this server's name/SSL cert paths
COPY buildbot_frontend.conf /etc/nginx/user_conf.d/${fqdn}.conf
COPY localhost_workaround.conf /etc/nginx/user_conf.d/localhost_workaround.conf
RUN sed -i.bak -e "s&{fqdn}&${fqdn}&g" /etc/nginx/user_conf.d/${fqdn}.conf
RUN rm -f /etc/nginx/user_conf.d/*.bak
