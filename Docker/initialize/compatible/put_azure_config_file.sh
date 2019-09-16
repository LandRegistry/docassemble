#! /bin/bash
if [ "${AZUREENABLE:-false}" == "true" ] && [[ ! $(python -m docassemble.webapp.list-cloud config.yml) ]]; then
    echo "Saving config" >&2
    blob-cmd -f cp "${DA_CONFIG_FILE}" "blob://${AZUREACCOUNTNAME}/${AZURECONTAINER}/config.yml"
fi