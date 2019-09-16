#! /bin/bash

if [ -n "$PACKAGES" ]; then
    for PACKAGE in "${PACKAGES[@]}"; do
        apt-get -q -y install $PACKAGE &> /dev/null
    done
fi