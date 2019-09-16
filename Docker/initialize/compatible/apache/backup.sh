#! /bin/bash

    if [ "${S3ENABLE:-false}" == "true" ]; then
        if [ "${USELETSENCRYPT:-false}" == "true" ]; then
            cd /
            rm -f /tmp/letsencrypt.tar.gz
            if [ -d etc/letsencrypt ]; then
                tar -zcf /tmp/letsencrypt.tar.gz etc/letsencrypt
                s3cmd -q put /tmp/letsencrypt.tar.gz "s3://${S3BUCKET}/letsencrypt.tar.gz"
                rm -f /tmp/letsencrypt.tar.gz
            fi
        fi
        if [[ $CONTAINERROLE =~ .*:(all):.* ]] || [[ ! $(python -m docassemble.webapp.list-cloud apache) ]]; then
            s3cmd -q sync /etc/apache2/sites-available/ "s3://${S3BUCKET}/apache/"
        fi
    elif [ "${AZUREENABLE:-false}" == "true" ]; then
        if [ "${USELETSENCRYPT:-false}" == "true" ]; then
            cd /
            rm -f /tmp/letsencrypt.tar.gz
            if [ -d etc/letsencrypt ]; then
                tar -zcf /tmp/letsencrypt.tar.gz etc/letsencrypt
                echo "Saving lets encrypt" >&2
                blob-cmd -f cp /tmp/letsencrypt.tar.gz "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/letsencrypt.tar.gz"
                rm -f /tmp/letsencrypt.tar.gz
            fi
        fi
        if [[ $CONTAINERROLE =~ .*:(all):.* ]] || [[ ! $(python -m docassemble.webapp.list-cloud apache) ]]; then
            for the_file in $(find /etc/apache2/sites-available/ -type f); do
                target_file=`basename "${the_file}"`
                echo "Saving apache" >&2
                blob-cmd -f cp "${the_file}" "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/apache/${target_file}"
            done
        fi
    else
        if [[ $CONTAINERROLE =~ .*:(all|lr|web):.* ]]; then
            if [ "${USELETSENCRYPT:-false}" == "true" ]; then
                cd /
                rm -f "${DA_ROOT}/backup/letsencrypt.tar.gz"
                tar -zcf "${DA_ROOT}/backup/letsencrypt.tar.gz" etc/letsencrypt
            fi
            rm -rf "${DA_ROOT}/backup/apache"
            mkdir -p "${DA_ROOT}/backup/apache"
            rsync -auq /etc/apache2/sites-available/ "${DA_ROOT}/backup/apache/"
        fi
    fi