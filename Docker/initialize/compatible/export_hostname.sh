#! /bin/bash

if [ "${EC2:-false}" == "true" ]; then
    export LOCAL_HOSTNAME=`curl -s http://169.254.169.254/latest/meta-data/local-hostname`
    export PUBLIC_HOSTNAME=`curl -s http://169.254.169.254/latest/meta-data/public-hostname`
else
    export LOCAL_HOSTNAME=`hostname --fqdn`
    export PUBLIC_HOSTNAME="${LOCAL_HOSTNAME}"
fi
