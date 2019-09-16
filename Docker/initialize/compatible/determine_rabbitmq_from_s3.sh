#! /bin/bash

if [ "${AZUREENABLE:-false}" == "true" ] && [[ $CONTAINERROLE =~ .*:(web):.* ]] && [[ $(python -m docassemble.webapp.list-cloud hostname-rabbitmq) ]] && [[ $(python -m docassemble.webapp.list-cloud ip-rabbitmq) ]]; then
    TEMPKEYFILE=`mktemp`
    echo "Copying hostname-rabbitmq" >&2
    blob-cmd -f cp "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/hostname-rabbitmq" "${TEMPKEYFILE}"
    HOSTNAMERABBITMQ=$(<$TEMPKEYFILE)
    echo "Copying ip-rabbitmq" >&2
    blob-cmd -f cp "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/ip-rabbitmq" "${TEMPKEYFILE}"
    IPRABBITMQ=$(<$TEMPKEYFILE)
    rm -f "${TEMPKEYFILE}"
    if [ -n "$(grep $HOSTNAMERABBITMQ /etc/hosts)" ]; then
        sed -i "/$HOSTNAMERABBITMQ/d" /etc/hosts
    fi
    echo "$IPRABBITMQ $HOSTNAMERABBITMQ" >> /etc/hosts
fi