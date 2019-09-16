#! /bin/bash


if [[ $CONTAINERROLE =~ .*:(log):.* ]] || [ "${LOGSERVER:-undefined}" == "null" ]; then
    OTHERLOGSERVER=false
fi