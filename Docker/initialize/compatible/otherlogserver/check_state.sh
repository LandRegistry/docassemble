#! /bin/bash


OTHERLOGSERVER=false

if [[ $CONTAINERROLE =~ .*:(lr|web|celery):.* ]]; then
    if [ "${LOGSERVER:-undefined}" != "undefined" ]; then
        OTHERLOGSERVER=true
    fi
fi
