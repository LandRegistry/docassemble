#! /bin/bash

if [ "${TIMEZONE:-undefined}" != "undefined" ] && [ -f /usr/share/zoneinfo/$TIMEZONE ]; then
    ln -fs /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    dpkg-reconfigure -f noninteractive tzdata
fi