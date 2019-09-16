#! /bin/bash

  su -c "source \"${DA_ACTIVATE}\" && python -m docassemble.webapp.deregister \"${DA_CONFIG_FILE}\"" docassemble
    if [ "${S3ENABLE:-false}" == "true" ] || [ "${AZUREENABLE:-false}" == "true" ]; then
        time su -c "source \"${DA_ACTIVATE}\" && python -m docassemble.webapp.cloud_deregister" docassemble
    fi
    if [[ $CONTAINERROLE =~ .*:(all|lr|web):.* ]]; then
        backup_apache
        rsync -auq /var/log/apache2/ "${LOGDIRECTORY}/" && chown -R www-data.www-data "${LOGDIRECTORY}"
    fi
    if [ "${S3ENABLE:-false}" == "true" ]; then
        if [[ $CONTAINERROLE =~ .*:(all|log):.* ]]; then
            s3cmd -q sync "${DA_ROOT}/log/" "s3://${S3BUCKET}/log/"
        fi
        if [[ $CONTAINERROLE =~ .*:(all):.* ]]; then
            s3cmd -q sync /var/log/apache2/ "s3://${S3BUCKET}/apachelogs/"
        fi
    elif [ "${AZUREENABLE:-false}" == "true" ]; then
        if [[ $CONTAINERROLE =~ .*:(all|log):.* ]]; then
            let LOGDIRECTORYLENGTH=${#LOGDIRECTORY}+2
            for the_file in $(find "${LOGDIRECTORY}" -type f | cut -c ${LOGDIRECTORYLENGTH}-); do
                echo "Saving log file $the_file" >&2
                blob-cmd -f cp "${LOGDIRECTORY}/${the_file}" "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/log/${the_file}"
            done
        fi
        if [[ $CONTAINERROLE =~ .*:(all):.* ]]; then
            for the_file in $(find /var/log/apache2 -type f | cut -c 18-); do
                echo "Saving log file $the_file" >&2
                blob-cmd -f cp "/var/log/apache2/${the_file}" "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/apachelogs/${the_file}"
            done
        fi
    else
        if [[ $CONTAINERROLE =~ .*:(all):.* ]]; then
            rm -rf "${DA_ROOT}/backup/apachelogs"
            mkdir -p "${DA_ROOT}/backup/apachelogs"
            rsync -auq /var/log/apache2/ "${DA_ROOT}/backup/apachelogs/"
        fi
        if [[ $CONTAINERROLE =~ .*:(all|log):.* ]]; then
            rm -rf "${DA_ROOT}/backup/log"
            rsync -auq "${LOGDIRECTORY}/" "${DA_ROOT}/backup/log/"
        fi
        if [[ $CONTAINERROLE =~ .*:(all|cron):.* ]]; then
            rm -f "${DA_ROOT}/backup/config.yml"
            cp "${DA_CONFIG_FILE}" "${DA_ROOT}/backup/config.yml"
            rm -rf "${DA_ROOT}/backup/files"
            rsync -auq "${DA_ROOT}/files" "${DA_ROOT}/backup/"
        fi
    fi
    echo "finished shutting down initialize" >&2