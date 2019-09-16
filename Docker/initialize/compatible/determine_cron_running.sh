#! /bin/bash

if [ -f /var/run/crond.pid ]; then
    CRON_PID=$(</var/run/crond.pid)
    if kill -0 $CRON_PID &> /dev/null; then
        CRONRUNNING=true
    else
        rm -f /var/run/crond.pid
        CRONRUNNING=false
    fi
else
    CRONRUNNING=false
fi