#! /bin/bash
if [ "${DAHOSTNAME:-none}" != "none" ]; then
    URLROOT="${URLROOT}${DAHOSTNAME}"
else
    if [ "${EC2:-false}" == "true" ]; then
        PUBLIC_HOSTNAME=`curl -s http://169.254.169.254/latest/meta-data/public-hostname`
    else
        PUBLIC_HOSTNAME=`hostname --fqdn`
    fi
    URLROOT="${URLROOT}${PUBLIC_HOSTNAME}"
fi