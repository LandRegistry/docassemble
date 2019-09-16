#! /bin/bash


if [ "${S3ENABLE:-false}" == "true" ]; then
    if [[ $CONTAINERROLE =~ .*:(all|web|lr):.* ]] && [[ $(s3cmd ls "s3://${S3BUCKET}/letsencrypt.tar.gz") ]]; then
        rm -f /tmp/letsencrypt.tar.gz
        s3cmd -q get "s3://${S3BUCKET}/letsencrypt.tar.gz" /tmp/letsencrypt.tar.gz
        cd /
        tar -xf /tmp/letsencrypt.tar.gz
        rm -f /tmp/letsencrypt.tar.gz
    fi
    if [[ $CONTAINERROLE =~ .*:(all|web|lr|log):.* ]] && [[ $(s3cmd ls "s3://${S3BUCKET}/apache") ]]; then
        s3cmd -q sync "s3://${S3BUCKET}/apache/" /etc/apache2/sites-available/
    fi
    if [[ $CONTAINERROLE =~ .*:(all):.* ]] && [[ $(s3cmd ls "s3://${S3BUCKET}/apachelogs") ]]; then
        s3cmd -q sync "s3://${S3BUCKET}/apachelogs/" /var/log/apache2/
        chown root.adm /var/log/apache2/*
        chmod 640 /var/log/apache2/*
    fi
    if [[ $CONTAINERROLE =~ .*:(all|log):.* ]] && [[ $(s3cmd ls "s3://${S3BUCKET}/log") ]]; then
        s3cmd -q sync "s3://${S3BUCKET}/log/" "${LOGDIRECTORY:-${DA_ROOT}/log}/"
        chown -R www-data.www-data "${LOGDIRECTORY:-${DA_ROOT}/log}"
    fi
    if [[ $(s3cmd ls "s3://${S3BUCKET}/config.yml") ]]; then
        rm -f "$DA_CONFIG_FILE"
        s3cmd -q get "s3://${S3BUCKET}/config.yml" "$DA_CONFIG_FILE"
        chown www-data.www-data "$DA_CONFIG_FILE"
    fi
    if [[ $CONTAINERROLE =~ .*:(all|lr|redis):.* ]] && [[ $(s3cmd ls "s3://${S3BUCKET}/redis.rdb") ]] && [ "$REDISRUNNING" = false ]; then
        s3cmd -q -f get "s3://${S3BUCKET}/redis.rdb" "/var/lib/redis/dump.rdb"
        chown redis.redis "/var/lib/redis/dump.rdb"
    fi
elif [ "${AZUREENABLE:-false}" == "true" ]; then
    if [[ $CONTAINERROLE =~ .*:(all|lr|web):.* ]] && [[ $(python -m docassemble.webapp.list-cloud letsencrypt.tar.gz) ]]; then
        rm -f /tmp/letsencrypt.tar.gz
        echo "Copying let's encrypt" >&2
        blob-cmd -f cp "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/letsencrypt.tar.gz" "/tmp/letsencrypt.tar.gz"
        cd /
        tar -xf /tmp/letsencrypt.tar.gz
        rm -f /tmp/letsencrypt.tar.gz
    fi
    if [[ $CONTAINERROLE =~ .*:(all|lr|web|log):.* ]] && [[ $(python -m docassemble.webapp.list-cloud apache/) ]]; then
        echo "There are apache files on Azure" >&2
        for the_file in $(python -m docassemble.webapp.list-cloud apache/ | cut -c 8-); do
            echo "Found $the_file on Azure" >&2
            if ! [[ $the_file =~ /$ ]]; then
                  echo "Copying apache file" $the_file >&2
                  blob-cmd -f cp "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/apache/${the_file}" "/etc/apache2/sites-available/${the_file}"
            fi
        done
    fi
    if [[ $CONTAINERROLE =~ .*:(all):.* ]] && [[ $(python -m docassemble.webapp.list-cloud apachelogs/) ]]; then
        echo "There are apache log files on Azure" >&2
        for the_file in $(python -m docassemble.webapp.list-cloud apachelogs/ | cut -c 12-); do
            echo "Found $the_file on Azure" >&2
            if ! [[ $the_file =~ /$ ]]; then
                echo "Copying log file $the_file" >&2
                blob-cmd -f cp "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/apachelogs/${the_file}" "/var/log/apache2/${the_file}"
            fi
        done
        chown root.adm /var/log/apache2/*
        chmod 640 /var/log/apache2/*
    fi
    if [[ $CONTAINERROLE =~ .*:(all|log):.* ]] && [[ $(python -m docassemble.webapp.list-cloud log) ]]; then
        echo "There are log files on Azure" >&2
        for the_file in $(python -m docassemble.webapp.list-cloud log/ | cut -c 5-); do
            echo "Found $the_file on Azure" >&2
            if ! [[ $the_file =~ /$ ]]; then
                echo "Copying log file $the_file" >&2
                blob-cmd -f cp "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/log/${the_file}" "${LOGDIRECTORY:-${DA_ROOT}/log}/${the_file}"
            fi
        done
        chown -R www-data.www-data "${LOGDIRECTORY:-${DA_ROOT}/log}"
    fi
    if [[ $(python -m docassemble.webapp.list-cloud config.yml) ]]; then
        rm -f "$DA_CONFIG_FILE"
        echo "Copying config.yml" >&2
        blob-cmd -f cp "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/config.yml" "${DA_CONFIG_FILE}"
        chown www-data.www-data "${DA_CONFIG_FILE}"
        ls -l "${DA_CONFIG_FILE}" >&2
    fi
    if [[ $CONTAINERROLE =~ .*:(all|lr|redis):.* ]] && [[ $(python -m docassemble.webapp.list-cloud redis.rdb) ]] && [ "$REDISRUNNING" = false ]; then
        echo "Copying redis" >&2
        blob-cmd -f cp "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/redis.rdb" "/var/lib/redis/dump.rdb"
        chown redis.redis "/var/lib/redis/dump.rdb"
    fi
else
    if [[ $CONTAINERROLE =~ .*:(all|lr|web):.* ]] && [ -f "${DA_ROOT}/backup/letsencrypt.tar.gz" ]; then
        cd /
        tar -xf "${DA_ROOT}/backup/letsencrypt.tar.gz"
    fi
    if [[ $CONTAINERROLE =~ .*:(all|lr|web|log):.* ]] && [ -d "${DA_ROOT}/backup/apache" ]; then
        rsync -auq "${DA_ROOT}/backup/apache/" /etc/apache2/sites-available/
    fi
    if [[ $CONTAINERROLE =~ .*:(all):.* ]] && [ -d "${DA_ROOT}/backup/apachelogs" ]; then
        rsync -auq "${DA_ROOT}/backup/apachelogs/" /var/log/apache2/
        chown root.adm /var/log/apache2/*
        chmod 640 /var/log/apache2/*
    fi
    if [[ $CONTAINERROLE =~ .*:(all|log):.* ]] && [ -d "${DA_ROOT}/backup/log" ]; then
        rsync -auq "${DA_ROOT}/backup/log/" "${LOGDIRECTORY:-${DA_ROOT}/log}/"
        chown -R www-data.www-data "${LOGDIRECTORY:-${DA_ROOT}/log}"
    fi
    if [ -f "${DA_ROOT}/backup/config.yml" ]; then
        cp "${DA_ROOT}/backup/config.yml" "${DA_CONFIG_FILE}"
        chown www-data.www-data "${DA_CONFIG_FILE}"
    fi
    if [ -d "${DA_ROOT}/backup/files" ]; then
        rsync -auq "${DA_ROOT}/backup/files" "${DA_ROOT}/"
        chown -R www-data.www-data "${DA_ROOT}/files"
    fi
    if [[ $CONTAINERROLE =~ .*:(all|lr|redis):.* ]] && [ -f "${DA_ROOT}/backup/redis.rdb" ] && [ "$REDISRUNNING" = false ]; then
        cp "${DA_ROOT}/backup/redis.rdb" /var/lib/redis/dump.rdb
        chown redis.redis "/var/lib/redis/dump.rdb"
    fi
fi