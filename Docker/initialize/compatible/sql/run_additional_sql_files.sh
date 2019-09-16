#! /bin/bash


if [ "$PGRUNNING" = true ] && [ "$DBTYPE" == "postgresql" ] && [ -d "/usr/share/docassemble/initialize/sql" ]; then
    ls  /usr/share/docassemble/initialize/sql/*.sql | xargs cat |  su -c psql postgres 
fi