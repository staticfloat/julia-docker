FROM nginx

ARG fqdn
ARG ssl_certificate_path
ARG ssl_certificate_key_path

# Deploy nginx configuration, templated properly for this server's name/SSL cert paths
RUN rm -f /etc/nginx/conf.d/*;
COPY nginx.conf /etc/nginx/conf.d/${fqdn}.conf
RUN sed -i.bak -e "s&{fqdn}&${fqdn}&g;s&{ssl_certificate_path}&${ssl_certificate_path}&g;s&{ssl_certificate_key_path}&${ssl_certificate_key_path}&g" /etc/nginx/conf.d/${fqdn}.conf
