#! /bin/bash

if [ "$CRONRUNNING" = false ]; then
    if ! grep -q '^CONTAINERROLE' /etc/crontab; then
        bash -c "set | grep -e '^CONTAINERROLE=' -e '^DA_PYTHON=' -e '^DA_CONFIG=' -e '^DA_ROOT=' -e '^DAPYTHONVERSION='; cat /etc/crontab" > /tmp/crontab && cat /tmp/crontab > /etc/crontab && rm -f /tmp/crontab
    fi
    time supervisorctl --serverurl http://localhost:9001 start cron
fi