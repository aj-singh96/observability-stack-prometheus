FROM nginx:alpine

RUN apk add --no-cache openssl apache2-utils curl jq py3-pip \
 && pip3 install --no-cache-dir --break-system-packages awscli

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443 9090 9093

ENTRYPOINT ["/entrypoint.sh"]
