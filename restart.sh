#!/bin/sh
NGINX=/usr/sbin/nginx
NGINX_CONF=/etc/nginx/nginx.conf
PID=/var/run/nginx.pid

echo "DEBUG: restarting nginx"
# gracefully restart nginx
${NGINX} -c ${NGINX_CONF} -t && \
kill -s HUP $(cat ${PID})
