#! /bin/bash

if [ -n "$OTHERLOCALES" ]; then
    NEWLOCALE=false
    for LOCALETOSET in "${OTHERLOCALES[@]}"; do
        grep -q "^$LOCALETOSET" /etc/locale.gen || { echo $LOCALETOSET >> /etc/locale.gen; NEWLOCALE=true; }
    done
    if [ "$NEWLOCALE" = true ]; then
        locale-gen
    fi
fi