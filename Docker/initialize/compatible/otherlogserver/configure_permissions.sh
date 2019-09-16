#! /bin/bash


if [ "$OTHERLOGSERVER" = false ] && [ -f "${LOGDIRECTORY}/docassemble.log" ]; then
    chown www-data.www-data "${LOGDIRECTORY}/docassemble.log"
fi