#!/bin/bash

export DA_ROOT="${DA_ROOT:-/usr/share/docassemble}"
export DAPYTHONVERSION="${DAPYTHONVERSION:-2}"
if [ "${DAPYTHONVERSION}" == "2" ]; then
    export DA_DEFAULT_LOCAL="local"
else
    export DA_DEFAULT_LOCAL="local3.5"
fi
export DA_ACTIVATE="${DA_PYTHON:-${DA_ROOT}/${DA_DEFAULT_LOCAL}}/bin/activate"
export DA_CONFIG_FILE="${DA_CONFIG:-${DA_ROOT}/config/config.yml}"
source /dev/stdin < <(su -c "source \"${DA_ACTIVATE}\" && python -m docassemble.base.read_config \"${DA_CONFIG_FILE}\"" www-data)

source "${DA_ACTIVATE}"

set -- $LOCALE
export LANG=$1

if [ "${S3ENABLE:-null}" == "null" ] && [ "${S3BUCKET:-null}" != "null" ]; then
    export S3ENABLE=true
fi

if [ "${S3ENABLE:-null}" == "true" ] && [ "${S3BUCKET:-null}" != "null" ] && [ "${S3ACCESSKEY:-null}" != "null" ] && [ "${S3SECRETACCESSKEY:-null}" != "null" ]; then
    export AWS_ACCESS_KEY_ID="${S3ACCESSKEY}"
    export AWS_SECRET_ACCESS_KEY="${S3SECRETACCESSKEY}"
fi

if [ "${AZUREENABLE:-null}" == "null" ] && [ "${AZUREACCOUNTNAME:-null}" != "null" ] && [ "${AZUREACCOUNTKEY:-null}" != "null" ] && [ "${AZURECONTAINER:-null}" != "null" ]; then
    export AZUREENABLE=true
fi

if [ "${AZUREENABLE:-false}" == "true" ]; then
    blob-cmd -f -v add-account "${AZUREACCOUNTNAME}" "${AZUREACCOUNTKEY}"
fi

function stopfunc {
    redis-cli shutdown
    echo backing up redis
    if [ "${S3ENABLE:-false}" == "true" ]; then
	s3cmd -q put "/var/lib/redis/dump.rdb" "s3://${S3BUCKET}/redis.rdb"
    elif [ "${AZUREENABLE:-false}" == "true" ]; then
	blob-cmd -f cp "/var/lib/redis/dump.rdb" "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/redis.rdb"
    else
	cp /var/lib/redis/dump.rdb "${DA_ROOT}/backup/redis.rdb"
    fi
    exit 0
}

trap stopfunc SIGINT SIGTERM
echo "starting redis server" >&2

redis-server /etc/redis/redis.conf & 
echo "starting redis server" >&2


echo "loading redis base data" >&2

redis_metrics=$(redis-cli ping)

echo "waiting for redis to be available" >&2;
COUNTER=0

STOP=false;
CONTINUE=true
if [[ $redis_metrics = PONG ]]; then 
        CONTINUE=false
fi
while $CONTINUE; do 
        let COUNTER+=1
        echo "$COUNTER [ $STOP ] [ $CONTINUE ] : waiting for 30 seconds" >&2
        sleep 0.5
        if [ $COUNTER -gt 20 ]; then
                STOP=true;
        fi;
        if $STOP; then 
                CONTINUE=false
        fi;
        if  [[ $redis_metrics == "PONG" ]] ; then
                CONTINUE=false
        fi
done;

for redisfile in /usr/share/docassemble/redis/*.redis; do 
        cat $redisfile | redis-cli --pipe
done
wait %1

#echo set "da:api:userid:1:key:B4BIU9HY9OUKY6TSGRJDCUMZN8CY2AQ2:info" "{\"name\":\"Default\",\"method\":\"none\",\"constraints\":[]}"| redis-cli --pipe