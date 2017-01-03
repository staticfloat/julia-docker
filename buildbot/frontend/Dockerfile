FROM nginx

ARG fqdn

# Deploy nginx configuration, templated properly for this server's name/SSL cert paths
RUN rm -f /etc/nginx/conf.d/*;
COPY nginx.conf /etc/nginx/conf.d/${fqdn}.conf
RUN sed -i.bak -e "s&{fqdn}&${fqdn}&g" /etc/nginx/conf.d/${fqdn}.conf
