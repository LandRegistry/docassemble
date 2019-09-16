#! /bin/bash


if [[ $CONTAINERROLE =~ *:(all|sql):* ]] && [ "$PGRUNNING" = false ] && [ "$DBTYPE" == "postgresql" ]; then

    supervisorctl --serverurl http://localhost:9001 start postgres || exit 1
    sleep 4
    su -c "while ! pg_isready -q; do sleep 1; done" postgres
    roleexists=`su -c "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${DBUSER:-docassemble}'\"" postgres`
    if [ -z "$roleexists" ]; then
        echo "create role "${DBUSER:-docassemble}" with login password '"${DBPASSWORD:-abc123}"';" | su -c psql postgres || exit 1
    fi
    if [ "${S3ENABLE:-false}" == "true" ] && [[ $(s3cmd ls s3://${S3BUCKET}/postgres) ]]; then
        PGBACKUPDIR=`mktemp -d`
        s3cmd -q sync "s3://${S3BUCKET}/postgres/" "$PGBACKUPDIR/"
    elif [ "${AZUREENABLE:-false}" == "true" ] && [[ $(python -m docassemble.webapp.list-cloud postgres) ]]; then
        echo "There are postgres files on Azure" >&2
        PGBACKUPDIR=`mktemp -d`
        for the_file in $(python -m docassemble.webapp.list-cloud postgres/); do
            echo "Found $the_file on Azure" >&2
            if ! [[ $the_file =~ /$ ]]; then
                target_file=`basename "${the_file}"`
                echo "Copying $the_file to $target_file" >&2
                blob-cmd -f cp "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/${the_file}" "$PGBACKUPDIR/${target_file}"
            fi
        done
    else
        PGBACKUPDIR="${DA_ROOT}/backup/postgres"
    fi

    if [ -d "${PGBACKUPDIR}" ]; then
        echo "Postgres database backup directory is $PGBACKUPDIR" >&2
        cd "$PGBACKUPDIR"
        chown -R postgres.postgres "$PGBACKUPDIR"
        for db in $( ls ); do
            echo "Restoring postgres database $db" >&2
            pg_restore -F c -C -c $db | su -c psql postgres
        done
        if [ "${S3ENABLE:-false}" == "true" ] || [ "${AZUREENABLE:-false}" == "true" ]; then
            cd /
            rm -rf $PGBACKUPDIR
        fi
        cd /tmp
    fi

    dbexists=`su -c "psql -tAc \"SELECT 1 FROM pg_database WHERE datname='${DBNAME:-docassemble}'\"" postgres`
    
    if [ -z "$dbexists" ]; then
        echo "create database "${DBNAME:-docassemble}" owner "${DBUSER:-docassemble}";" | su -c psql postgres || exit 1
    fi

fi
