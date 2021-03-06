#! /bin/bash


if [[ $CONTAINERROLE =~ .*:(all|lr|web):.* ]] && [ "$APACHERUNNING" = false ]; then
    echo "Listen 80" > /etc/apache2/ports.conf
    if [ "${DAPYTHONMANUAL:-0}" == "0" ]; then
        if [ "${DAPYTHONVERSION}" == "2" ]; then
            WSGI_VERSION=`apt-cache policy libapache2-mod-wsgi | grep '^  Installed:' | awk '{print $2}'`
            if [ "${WSGI_VERSION}" != '4.3.0-1' ]; then
                cd /tmp && dpkg -i /tmp/docassemble/installers/libapache2-mod-wsgi_4.3.0-1_amd64.deb
            fi
        else
            WSGI_VERSION=`apt-cache policy libapache2-mod-wsgi-py3 | grep '^  Installed:' | awk '{print $2}'`
            if [ "${WSGI_VERSION}" != '4.5.11-1' ]; then
                apt-get -q -y install libapache2-mod-wsgi-py3 &> /dev/null
            fi
        fi
    fi

    if [ "${DAPYTHONMANUAL:-0}" == "0" ]; then
        a2enmod wsgi &> /dev/null
    else
        a2dismod wsgi &> /dev/null
    fi

    if [ "${WWWUID:-none}" != "none" ] && [ "${WWWGID:-none}" != "none" ] && [ `id -u www-data` != $WWWUID ]; then
        OLDUID=`id -u www-data`
        OLDGID=`id -g www-data`

        usermod -o -u $WWWUID www-data
        groupmod -o -g $WWWGID www-data
        find / -user $OLDUID -exec chown -h www-data {} \;
        find / -group $OLDGID -exec chgrp -h www-data {} \;
        if [[ $CONTAINERROLE =~ .*:(all|lr|celery):.* ]] && [ "$CELERYRUNNING" = false ]; then
            supervisorctl --serverurl http://localhost:9001 stop celery
        fi
        supervisorctl --serverurl http://localhost:9001 reread
        supervisorctl --serverurl http://localhost:9001 update
        if [[ $CONTAINERROLE =~ .*:(all|lr|celery):.* ]] && [ "$CELERYRUNNING" = false ]; then
            supervisorctl --serverurl http://localhost:9001 start celery
        fi
    fi

    if [ "${BEHINDHTTPSLOADBALANCER:-false}" == "true" ]; then
        a2enmod remoteip
        a2enconf docassemble-behindlb
    else
        a2dismod remoteip
        a2disconf docassemble-behindlb
    fi

    echo -e "# This file is automatically generated" > /etc/apache2/conf-available/docassemble.conf
    if [ "${DAPYTHONMANUAL:-0}" == "3" ]; then
        echo -e "LoadModule wsgi_module ${DA_PYTHON:-${DA_ROOT}/${DA_DEFAULT_LOCAL}}/lib/python3.5/site-packages/mod_wsgi/server/mod_wsgi-py35.cpython-35m-x86_64-linux-gnu.so" >> /etc/apache2/conf-available/docassemble.conf
    fi
    
    
    
    echo -e "<IfModule mod_wsgi.c>" >> /etc/apache2/conf-available/docassemble.conf
    echo -e "WSGIPythonHome ${DA_PYTHON:-${DA_ROOT}/${DA_DEFAULT_LOCAL}}" >> /etc/apache2/conf-available/docassemble.conf
    echo -e "</IfModule>" >> /etc/apache2/conf-available/docassemble.conf

    echo -e "Timeout ${DATIMEOUT:-60}\nDefine DAHOSTNAME ${DAHOSTNAME}\nDefine DAPOSTURLROOT ${POSTURLROOT}\nDefine DAWSGIROOT ${WSGIROOT}\nDefine DASERVERADMIN ${SERVERADMIN}\nDefine DAWEBSOCKETSIP ${DAWEBSOCKETSIP}\nDefine DAWEBSOCKETSPORT ${DAWEBSOCKETSPORT}\nDefine DACROSSSITEDOMAINVALUE *" >> /etc/apache2/conf-available/docassemble.conf
    if [ "${BEHINDHTTPSLOADBALANCER:-false}" == "true" ]; then
        echo "Listen 8081" >> /etc/apache2/ports.conf
        a2ensite docassemble-redirect
    fi
    if [ "${USEHTTPS:-false}" == "true" ]; then
        echo "Listen 443" >> /etc/apache2/ports.conf
        a2enmod ssl
        a2ensite docassemble-ssl
        if [ "${USELETSENCRYPT:-false}" == "true" ]; then
            cd "${DA_ROOT}/letsencrypt"
            if [ -f /etc/letsencrypt/da_using_lets_encrypt ]; then
                ./letsencrypt-auto renew
            else
                ./letsencrypt-auto --apache --quiet --email "${LETSENCRYPTEMAIL}" --agree-tos --redirect -d "${DAHOSTNAME}" && touch /etc/letsencrypt/da_using_lets_encrypt
            fi
            cd ~-
            /etc/init.d/apache2 stop
        else
            rm -f /etc/letsencrypt/da_using_lets_encrypt
        fi
    else
        rm -f /etc/letsencrypt/da_using_lets_encrypt
        a2dismod ssl
        a2dissite -q docassemble-ssl &> /dev/null
    fi
    backup_apache
fi