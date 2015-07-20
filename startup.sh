#!/bin/bash
NGINX=/usr/sbin/nginx
NGINX_CONF=/etc/nginx/nginx.conf
NGINX_TEMPLATE=/etc/nginx/nginx.conf.ctmpl
CONSUL_CONFIG_COMMAND=/consul_config.sh
RESTART_COMMAND=/restart.sh

# set initial data to consul key-value store
${CONSUL_CONFIG_COMMAND}

# start nginx with default setting
${NGINX} -c ${NGINX_CONF} -t && \
	${NGINX} -c ${NGINX_CONF} -g "daemon on;"

# start consul-template
/usr/local/bin/consul-template \
    -log-level ${LOG_LEVEL:-warn} \
    -consul ${CONSUL_PORT_8500_TCP_ADDR:-localhost}:${CONSUL_PORT_8500_TCP_PORT:-8500} \
    -template "${NGINX_TEMPLATE}:${NGINX_CONF}:${RESTART_COMMAND} || true" \
