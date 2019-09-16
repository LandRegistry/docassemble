#! /bin/bash

if [ "${AZUREENABLE:-false}" == "true" ]; then
    echo "Initializing azure" >&2
    blob-cmd -f -v add-account "${AZUREACCOUNTNAME}" "${AZUREACCOUNTKEY}"
fi
