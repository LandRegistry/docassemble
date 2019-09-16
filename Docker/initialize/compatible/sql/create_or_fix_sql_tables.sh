#! /bin/bash

if [[ $CONTAINERROLE =~ .*:(all|lr|sql|cron):.* ]]; then

    if [ "$PGRUNNING" = "true" ] && [ "$DBTYPE" == "postgresql" ]; then
        echo "Running  docassemble.webapp.fix_postgresql_tables \"${DA_CONFIG_FILE}\" ";
        echo "Running  docassemble.webapp.create_tables \"${DA_CONFIG_FILE}\" ";
        time su -c "source \"${DA_ACTIVATE}\" && python -m docassemble.webapp.fix_postgresql_tables \"${DA_CONFIG_FILE}\" && python -m docassemble.webapp.create_tables \"${DA_CONFIG_FILE}\"" docassemble
    fi
fi