#! /bin/bash

if [[ $CONTAINERROLE =~ .*:(all|mail):.* && ($DBTYPE = "postgresql" || $DBTYPE = "mysql") ]]; then
    if [ "${DBTYPE}" = "postgresql" ]; then
        cp "${DA_ROOT}/config/exim4-router-postgresql" /etc/exim4/dbrouter
        if [ "${DBHOST:-null}" != "null" ]; then
            echo -n 'hide pgsql_servers = '${DBHOST} > /etc/exim4/dbinfo
        else
            echo -n 'hide pgsql_servers = localhost' > /etc/exim4/dbinfo
        fi
        if [ "${DBPORT:-null}" != "null" ]; then
            echo -n '::'${DBPORT} >> /etc/exim4/dbinfo
        fi
        echo '/'${DBNAME}'/'${DBUSER}'/'${DBPASSWORD} >> /etc/exim4/dbinfo
    fi
    if [ "$DBTYPE" = "mysql" ]; then
        cp "${DA_ROOT}/config/exim4-router-mysql" /etc/exim4/dbrouter
        if [ "${DBHOST:-null}" != "null" ]; then
            echo -n 'hide mysql_servers = '${DBHOST} > /etc/exim4/dbinfo
        else
            echo -n 'hide mysql_servers = localhost' > /etc/exim4/dbinfo
        fi
        if [ "${DBPORT:-null}" != "null" ]; then
            echo -n '::'${DBPORT} >> /etc/exim4/dbinfo
        fi
        echo '/'${DBNAME}'/'${DBUSER}'/'${DBPASSWORD} >> /etc/exim4/dbinfo
    fi
    if [ "${DBTYPE}" = "postgresql" ]; then
        echo 'DAQUERY = select short from '${DBTABLEPREFIX}"shortener where short='\${quote_pgsql:\$local_part}'" >> /etc/exim4/dbinfo
    fi
    if [ "${DBTYPE}" = "mysql" ]; then
        echo 'DAQUERY = select short from '${DBTABLEPREFIX}"shortener where short='\${quote_mysql:\$local_part}'" >> /etc/exim4/dbinfo
    fi
    if [ -f /etc/ssl/docassemble/exim.crt ] && [ -f /etc/ssl/docassemble/exim.key ]; then
        cp /etc/ssl/docassemble/exim.crt /etc/exim4/exim.crt
        cp /etc/ssl/docassemble/exim.key /etc/exim4/exim.key
        chown root.Debian-exim /etc/exim4/exim.crt
        chown root.Debian-exim /etc/exim4/exim.key
        chmod 640 /etc/exim4/exim.crt
        chmod 640 /etc/exim4/exim.key
        echo 'MAIN_TLS_ENABLE = yes' >> /etc/exim4/dbinfo
    elif [[ $CONTAINERROLE =~ .*:(all|lr|web):.* ]] && [ "${USELETSENCRYPT:-false}" == "true" ] && [ -f "/etc/letsencrypt/live/${DAHOSTNAME}/cert.pem" ] && [ -f "/etc/letsencrypt/live/${DAHOSTNAME}/privkey.pem" ]; then
        cp "/etc/letsencrypt/live/${DAHOSTNAME}/fullchain.pem" /etc/exim4/exim.crt
        cp "/etc/letsencrypt/live/${DAHOSTNAME}/privkey.pem" /etc/exim4/exim.key
        chown root.Debian-exim /etc/exim4/exim.crt
        chown root.Debian-exim /etc/exim4/exim.key
        chmod 640 /etc/exim4/exim.crt
        chmod 640 /etc/exim4/exim.key
        echo 'MAIN_TLS_ENABLE = yes' >> /etc/exim4/dbinfo
    else
        echo 'MAIN_TLS_ENABLE = no' >> /etc/exim4/dbinfo
    fi
    chmod og-rwx /etc/exim4/dbinfo
    supervisorctl --serverurl http://localhost:9001 start exim4
fi