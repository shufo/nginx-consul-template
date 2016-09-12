nginx-consul-template
==============================

DockerHub Repository: https://registry.hub.docker.com/u/shufo/nginx-consul-template/

## Overview

This repository contains a scripts for creating configurable load balancer [Consul](https://www.consul.io/) Key-Value store API with [nginx](http://nginx.org/en/) and [consul-template](https://github.com/hashicorp/consul-template).

## Requirements

- [Docker](https://www.docker.com/) (Tested on 1.6.2)
- [Consul](https://www.consul.io/) (Tested on 0.5.2)

## Usage

- Run 

```
docker run -d -p 80:80 \
    --link consul:consul \
    -e "CONSUL_KV_PREFIX=nginx" \
    shufo/nginx-consul-template
```

- Custom nginx config

Inside the container there is a file `config.json` which contains default values for all of the configuration
options that are read by the consul template. When this container starts these default values are pre-loaded
into consul, so that when it comes to reading these values when the template is parsed, there are already default
values.

However you can change these default values by providing your own `config.json`:

```
docker run -d -p 80:80 \
    -v /path/to/config.json:/config.json \
    --link consul:consul \
    -e "CONSUL_KV_PREFIX=nginx" \
    shufo/nginx-consul-template
```

- Custom template

```
docker run -d -p 80:80 \
    -v $(pwd)/config.json:/config.json \
    -v /path/to/nginx.conf.ctmpl:/etc/nginx/nginx.conf.ctmpl \
    -e "CONSUL_KV_PREFIX=nginx" \
    shufo/nginx-consul-template
```

- Dynamic configuration change via Consul API.

```
curl -X PUT -d "/var/log/nginx/error.log" http://consul_host:8500/v1/kv/nginx/error_log
```

- Changing the consul hostname

By default this container tries to connect to a consul server running on localhost. If you want to specify a different
location for the consul server, set the `CONSUL_PORT_8500_TCP_ADDR` environmental variable. If you are linking this
container to the consul container then you should set the `CONSUL_PORT_8500_TCP_ADDR` variable to the alias of the
consul container:
```
docker run -d -p 80:80 \
    -v /path/to/config.json:/config.json \
    --link consul:consul \
    -e "CONSUL_KV_PREFIX=nginx" \
    -e "CONSUL_PORT_8500_TCP_ADDR=consul" \
    shufo/nginx-consul-template
```


## Example

This repository contains a example dockerize application build with vagrant machine.(Requires [Vagrant](https://www.vagrantup.com/) and [Ansible](http://docs.ansible.com/intro_installation.html))

- Setup VM and docker containers.

```
make install
```

- Change configuration.

```
curl -X PUT -d "/var/log/nginx/error.log" http://172.17.9.101:8500/v1/kv/nginx/error_log
```

- Ensure nginx conf is properly rewrited.

```
docker exec -it nodes_nginx_1 cat /etc/nginx/nginx.conf
```

- Set tag to application upstream.

```
curl -X PUT -d "0.0.1" http://172.17.9.101:8500/v1/kv/nginx/http/server/httpd/upstream/current
```

This will set upstream of service named `httpd` to tagged with `0.0.1` containers. Service registration is automated by [registrator](https://registry.hub.docker.com/u/sttts/registrator/).

- If something goes wrong, restart all containers

```
make restart
```

## How to

- Consul data persistence

```
docker run -d -v /mnt:/data progrium/consul:latest -server -bootstrap -data-dir /data -ui-dir /ui
```

- Set multiple value in same key

```
# Edit config.json
# Set JSON key-value pair as a Value.
"location": {
"proxy_set_header": "{\"X-Real-IP\": \"$remote_addr\", \"X-Forwarded-For\": \"$proxy_add_x_forwarded_for\", \"X-Forwarded-Proto\": \"$scheme\", \"Host\": \"$host\"}"
}

# Edit consul template file
{{ range $key, $pairs := tree "location" | byKey }}
  {{ range $pair := $pairs }}
    {{ range $key, $value := printf "location/%s"  $pair.Key | key | parseJSON }}
    	{{ $key }}{{ $value }}
    {{ end }}
  {{ end }}
{{ end }}
```

- Run with Host networking

```
docker run -d --net host -v $(pwd)/config.json:/config.json -e "CONSUL_KV_PREFIX=nginx" -e "CONSUL_PORT_8500_TCP_ADDR=CONSUL_HOST_IP" shufo/nginx-consul-template
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
