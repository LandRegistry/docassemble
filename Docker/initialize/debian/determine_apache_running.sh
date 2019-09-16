#! /bin/bash

if [ -f /var/run/apache2/apache2.pid ]; then
    APACHE_PID=$(</var/run/apache2/apache2.pid)
    if kill -0 $APACHE_PID &> /dev/null; then
        APACHERUNNING=true
    else
        rm -f /var/run/apache2/apache2.pid
        APACHERUNNING=false
    fi
else
    APACHERUNNING=false
fi