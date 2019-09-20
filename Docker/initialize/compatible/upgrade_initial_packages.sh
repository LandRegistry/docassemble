#! /bin/bash

if [ "${DAUPDATEONSTART:-true}" = "initial" ] && [ ! -f "${DA_ROOT}/webapp/initialized" ]; then
    echo "Doing initial upgrading of python packages" >&2
    time su -c "source \"${DA_ACTIVATE}\" && python -m docassemble.webapp.update \"${DA_CONFIG_FILE}\" initialize"  www-data || exit 1
    echo "Finished upgrading packages"
    touch "${DA_ROOT}/webapp/initialized"
fi