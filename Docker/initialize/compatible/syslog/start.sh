#! /bin/bash


if [[ $CONTAINERROLE =~ .*:(log):.* ]] || [ "$OTHERLOGSERVER" = true ]; then
    if [ -d /etc/syslog-ng ]; then
        if [ "$OTHERLOGSERVER" = true ]; then
            cp "${DA_ROOT}/webapp/syslog-ng-docker.conf" /etc/syslog-ng/syslog-ng.conf
            cp "${DA_ROOT}/webapp/docassemble-syslog-ng.conf" /etc/syslog-ng/conf.d/docassemble.conf
            sleep 5s
        else
            rm -f /etc/syslog-ng/conf.d/docassemble.conf
            cp "${DA_ROOT}/webapp/syslog-ng.conf" /etc/syslog-ng/syslog-ng.conf
        fi
        supervisorctl --serverurl http://localhost:9001 start syslogng
    fi
fi
