#!/bin/bash
#
# Init Consul key-value store based on static json config file
# Requires: jq - a lightweight and flexible command-line JSON processor - installed on system.

# settings
CONFIG_JSON=${CONFIG_JSON:-/config.json}
CONFIG=$(cat ${CONFIG_JSON})
CONSUL_KV_PREFIX=${CONSUL_KV_PREFIX}

has_value() {
    type=$(echo "$1" | jq -r -e "$2 | type")
    [ ${type} = 'array' -o ${type} = 'string' ]
}

get_value(){
    type=$(echo "$1" | jq -r -e "$2 | type")
    if [ ${type} = 'array' ]; then
        result=$(echo "$1" | jq -r -e "$2 | .[]")
    else
        result=$(echo "$1" | jq -r -e "$2")
    fi
    echo $result
}

declare -A N

echo "#[consul settings]"

# load config
paths=$(echo ${CONFIG} | jq -r -e '[path(..)|map(if type=="number" then "[]" else tostring end)|join(".")|split(".[]")|join("[]")]|unique|map("."+.)|.[]')
IFS=$'\n'
paths=($(echo "${paths}"))
for line in ${paths[@]};do
    if has_value "${CONFIG}" "${line}"; then
        uri=$(echo $line | sed -e 's/\./\//g')
        N["$uri"]=$(get_value "${CONFIG}" "$line")
    fi
done

# register to consul key-value store
for i in ${!N[@]}; do
    echo "#[INFO] ${i} => [${N[$i]}]"
    curl -sSL -X PUT -d "${N[$i]}" http://${CONSUL_PORT_8500_TCP_ADDR:-127.0.0.1}:${CONSUL_PORT_8500_TCP_PORT:-8500}/v1/kv/${CONSUL_KV_PREFIX}${i} > /dev/null 2>&1
done