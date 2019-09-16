#! /bin/bash


if [[ $CONTAINERROLE =~ .*:(all|lr|web):.* ]]; then
    supervisorctl --serverurl http://localhost:9001 start websockets
fi