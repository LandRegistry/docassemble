#! /bin/bash

if [[ $CONTAINERROLE =~ .*:(all|web|lr|log):.* ]]; then
    a2dissite -q 000-default &> /dev/null
    a2dissite -q default-ssl &> /dev/null
    rm -f /etc/apache2/sites-available/000-default.conf
    rm -f /etc/apache2/sites-available/default-ssl.conf
    if [ "${DAHOSTNAME:-none}" != "none" ]; then
        if [ ! -f /etc/apache2/sites-available/docassemble-ssl.conf ]; then
            cp "${DA_ROOT}/config/docassemble-ssl.conf.dist" /etc/apache2/sites-available/docassemble-ssl.conf
            rm -f /etc/letsencrypt/da_using_lets_encrypt
        fi
        if [ ! -f /etc/apache2/sites-available/docassemble-http.conf ]; then
            cp "${DA_ROOT}/config/docassemble-http.conf.dist" /etc/apache2/sites-available/docassemble-http.conf
            rm -f /etc/letsencrypt/da_using_lets_encrypt
        fi
        if [ ! -f /etc/apache2/sites-available/docassemble-log.conf ]; then
            cp "${DA_ROOT}/config/docassemble-log.conf.dist" /etc/apache2/sites-available/docassemble-log.conf
        fi
        if [ ! -f /etc/apache2/sites-available/docassemble-redirect.conf ]; then
            cp "${DA_ROOT}/config/docassemble-redirect.conf.dist" /etc/apache2/sites-available/docassemble-redirect.conf
        fi
    else
        if [ ! -f /etc/apache2/sites-available/docassemble-http.conf ]; then
            cp "${DA_ROOT}/config/docassemble-http.conf.dist" /etc/apache2/sites-available/docassemble-http.conf || exit 1
        fi
    fi
    a2ensite docassemble-http
fi