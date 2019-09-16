#! /bin/bash

if [ "${DAHOSTNAME:-none}" == "none" ]; then
    export DAHOSTNAME="${PUBLIC_HOSTNAME}"
fi