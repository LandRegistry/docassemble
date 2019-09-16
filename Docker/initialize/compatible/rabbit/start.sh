#! /bin/bash

if [[ $CONTAINERROLE =~ .*:(all|rabbitmq):.* ]] && [ "$RABBITMQRUNNING" = false ]; then
    echo "Starting rabbit"
    time supervisorctl --serverurl http://localhost:9001 start rabbitmq
    echo "Finished starting rabbit"
fi