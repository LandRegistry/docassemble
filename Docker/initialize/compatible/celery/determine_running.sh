#! /bin/bash

if su -c "source \"${DA_ACTIVATE}\" && celery -A docassemble.webapp.worker status" docassemble 2>&1 | grep -q `hostname`; then
    CELERYRUNNING=true;
else
    CELERYRUNNING=false;
fi