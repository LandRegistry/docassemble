#! /bin/bash

if [ "${BEHINDHTTPSLOADBALANCER:-null}" == "true" ] && [ "${XSENDFILE:-null}" == "null" ]; then
    export XSENDFILE=false
fi

if [ ! -f "$DA_CONFIG_FILE" ]; then
    echo "There is no config file.  Creating one from source." >&2
    sed -e 's@{{DBPREFIX}}@'"${DBPREFIX:-postgresql+psycopg2:\/\/}"'@' \
        -e 's/{{DBNAME}}/'"${DBNAME:-docassemble}"'/' \
        -e 's/{{DBUSER}}/'"${DBUSER:-docassemble}"'/' \
        -e 's#{{DBPASSWORD}}#'"${DBPASSWORD:-abc123}"'#' \
        -e 's/{{DBHOST}}/'"${DBHOST:-null}"'/' \
        -e 's/{{DBPORT}}/'"${DBPORT:-null}"'/' \
        -e 's/{{DBTABLEPREFIX}}/'"${DBTABLEPREFIX:-null}"'/' \
        -e 's/{{S3ENABLE}}/'"${S3ENABLE:-false}"'/' \
        -e 's#{{S3ACCESSKEY}}#'"${S3ACCESSKEY:-null}"'#' \
        -e 's#{{S3SECRETACCESSKEY}}#'"${S3SECRETACCESSKEY:-null}"'#' \
        -e 's/{{S3BUCKET}}/'"${S3BUCKET:-null}"'/' \
        -e 's/{{S3REGION}}/'"${S3REGION:-null}"'/' \
        -e 's/{{AZUREENABLE}}/'"${AZUREENABLE:-false}"'/' \
        -e 's/{{AZUREACCOUNTNAME}}/'"${AZUREACCOUNTNAME:-null}"'/' \
        -e 's@{{AZUREACCOUNTKEY}}@'"${AZUREACCOUNTKEY:-null}"'@' \
        -e 's/{{AZURECONTAINER}}/'"${AZURECONTAINER:-null}"'/' \
        -e 's/{{DABACKUPDAYS}}/'"${DABACKUPDAYS:-14}"'/' \
        -e 's@{{REDIS}}@'"${REDIS:-null}"'@' \
        -e 's#{{RABBITMQ}}#'"${RABBITMQ:-null}"'#' \
        -e 's@{{TIMEZONE}}@'"${TIMEZONE:-null}"'@' \
        -e 's/{{EC2}}/'"${EC2:-false}"'/' \
        -e 's/{{USEHTTPS}}/'"${USEHTTPS:-false}"'/' \
        -e 's/{{USELETSENCRYPT}}/'"${USELETSENCRYPT:-false}"'/' \
        -e 's/{{LETSENCRYPTEMAIL}}/'"${LETSENCRYPTEMAIL:-null}"'/' \
        -e 's@{{LOGSERVER}}@'"${LOGSERVER:-null}"'@' \
        -e 's/{{DAHOSTNAME}}/'"${DAHOSTNAME:-none}"'/' \
        -e 's/{{LOCALE}}/'"${LOCALE:-null}"'/' \
        -e 's/{{SERVERADMIN}}/'"${SERVERADMIN:-webmaster@localhost}"'/' \
        -e 's@{{DASECRETKEY}}@'"${DEFAULT_SECRET}"'@' \
        -e 's@{{URLROOT}}@'"${URLROOT:-null}"'@' \
        -e 's@{{POSTURLROOT}}@'"${POSTURLROOT:-/}"'@' \
        -e 's/{{BEHINDHTTPSLOADBALANCER}}/'"${BEHINDHTTPSLOADBALANCER:-false}"'/' \
        -e 's/{{XSENDFILE}}/'"${XSENDFILE:-true}"'/' \
        -e 's/{{DAEXPOSEWEBSOCKETS}}/'"${DAEXPOSEWEBSOCKETS:-false}"'/' \
        -e 's/{{DAWEBSOCKETSIP}}/'"${DAWEBSOCKETSIP:-null}"'/' \
        -e 's/{{DAWEBSOCKETSPORT}}/'"${DAWEBSOCKETSPORT:-null}"'/' \
        -e 's/{{DAUPDATEONSTART}}/'"${DAUPDATEONSTART:-true}"'/' \
        "$DA_CONFIG_FILE_DIST" > "$DA_CONFIG_FILE" || exit 1
fi

chown www-data.www-data "$DA_CONFIG_FILE"