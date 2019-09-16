#! /bin/bash


if [[ $CONTAINERROLE =~ .*:(all|lr|web|log):.* ]] && [ "$APACHERUNNING" = false ]; then
    supervisorctl --serverurl http://localhost:9001 start apache2
fi