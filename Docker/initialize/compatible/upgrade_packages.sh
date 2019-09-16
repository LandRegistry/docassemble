#! /bin/bash


if [ "${DAUPDATEONSTART:-true}" = "true" ]; then
    echo "Doing upgrading of packages" >&2
    time su -c "source \"${DA_ACTIVATE}\" && python -m docassemble.webapp.update \"${DA_CONFIG_FILE}\" initialize" docassemble || exit 1
    echo "Finished upgrading packages"
    touch "${DA_ROOT}/webapp/initialized"
fi