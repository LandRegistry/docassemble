#! /bin/bash

if [[ $CONTAINERROLE =~ .*:(log):.* ]] && [ "$APACHERUNNING" = false ]; then
    echo "Listen 8080" >> /etc/apache2/ports.conf
    a2enmod cgid
    a2ensite docassemble-log
fi