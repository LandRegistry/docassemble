#! /bin/bash

if [[ $CONTAINERROLE =~ .*:(all|web|lr|log):.* ]] && [ "$APACHERUNNING" = false ]; then
    rm -f /etc/apache2/ports.conf
fi