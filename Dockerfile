FROM nginx:latest

MAINTAINER shufo <meikyowise@gmail.com>

RUN apt-get update && apt-get install -y --no-install-recommends curl
RUN curl -SL https://github.com/hashicorp/consul-template/releases/download/v0.10.0/consul-template_0.10.0_linux_amd64.tar.gz | \
    tar -xvzC /usr/local/bin --strip-components 1 && \
    rm -v /etc/nginx/conf.d/* && \
	curl -SL http://stedolan.github.io/jq/download/linux64/jq > /usr/local/bin/jq && chmod u+x /usr/local/bin/jq

ADD nginx.conf /etc/nginx/nginx.conf
ADD nginx.conf.ctmpl /etc/nginx/nginx.conf.ctmpl

ADD startup.sh restart.sh consul_config.sh config.json /
RUN chmod u+x /startup.sh && \
    chmod u+x /restart.sh && \
    chmod u+x /consul_config.sh

WORKDIR /

EXPOSE 80 443

CMD ["/startup.sh"]
