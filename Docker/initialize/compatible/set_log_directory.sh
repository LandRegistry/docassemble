#! /bin/bash

su -c   "source \"${DA_ACTIVATE}\" && python -m docassemble.base.read_config \"${DA_CONFIG_FILE}\"  www-data"

export LOGDIRECTORY="${LOGDIRECTORY:-${DA_ROOT}/log}"