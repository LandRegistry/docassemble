#! /bin/bash
if [ "${S3ENABLE:-false}" == "true" ] || [ "${AZUREENABLE:-false}" == "true" ]; then
    time su -c "source \"${DA_ACTIVATE}\" && python -m docassemble.webapp.cloud_register \"${DA_CONFIG_FILE}\"" www-data
fi