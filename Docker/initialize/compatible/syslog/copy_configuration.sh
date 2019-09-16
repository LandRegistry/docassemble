#! /bin/bash


if [ -f /etc/syslog-ng/syslog-ng.conf ] && [ ! -f "${DA_ROOT}/webapp/syslog-ng-orig.conf" ]; then
    cp /etc/syslog-ng/syslog-ng.conf "${DA_ROOT}/webapp/syslog-ng-orig.conf"
fi
