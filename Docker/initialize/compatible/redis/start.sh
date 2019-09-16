#! /bin/bash

if [[ $CONTAINERROLE =~ .*:(all|lr|redis):.* ]] && [ "$REDISRUNNING" = false ]; then
    supervisorctl --serverurl http://localhost:9001 start redis
fi