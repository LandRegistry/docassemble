#! /bin/bash

if [[ $CONTAINERROLE =~ .*:(all|lr|web):.* ]]; then
    if [ "${USEHTTPS:-false}" == "false" ]; then
        curl -s http://localhost/ > /dev/null
    else
        curl -s -k https://localhost/ > /dev/null
    fi
    if [ "$APACHERUNNING" = false ]; then
        supervisorctl --serverurl http://localhost:9001 stop apache2
        supervisorctl --serverurl http://localhost:9001 start apache2
    fi
fi