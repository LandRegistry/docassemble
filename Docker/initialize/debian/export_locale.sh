#! /bin/bash


set -- $LOCALE
DA_LANGUAGE=$1
export LANG=$1

grep -q "^$LOCALE" /etc/locale.gen || { echo $LOCALE >> /etc/locale.gen && locale-gen ; }
update-locale LANG="${DA_LANGUAGE}"