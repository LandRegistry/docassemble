#! /bin/bash

if [[ $CONTAINERROLE =~ .*:(all|celery):.* ]] && [ "$CELERYRUNNING" = false ]; then
    echo "starting celery"
    time supervisorctl --serverurl http://localhost:9001 start celery
    echo "finished starting celery"
fi
