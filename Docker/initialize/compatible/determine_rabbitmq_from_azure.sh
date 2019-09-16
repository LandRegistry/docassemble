#! /bin/bash

if [ "${S3ENABLE:-false}" == "true" ] && [[ $CONTAINERROLE =~ .*:(web):.* ]] && [[ $(s3cmd ls s3://${S3BUCKET}/hostname-rabbitmq) ]] && [[ $(s3cmd ls s3://${S3BUCKET}/ip-rabbitmq) ]]; then
    TEMPKEYFILE=`mktemp`
    s3cmd -q -f get s3://${S3BUCKET}/hostname-rabbitmq $TEMPKEYFILE
    HOSTNAMERABBITMQ=$(<$TEMPKEYFILE)
    s3cmd -q -f get s3://${S3BUCKET}/ip-rabbitmq $TEMPKEYFILE
    IPRABBITMQ=$(<$TEMPKEYFILE)
    rm -f $TEMPKEYFILE
    if [ -n "$(grep $HOSTNAMERABBITMQ /etc/hosts)" ]; then
        sed -i "/$HOSTNAMERABBITMQ/d" /etc/hosts
    fi
    echo "$IPRABBITMQ $HOSTNAMERABBITMQ" >> /etc/hosts
fi