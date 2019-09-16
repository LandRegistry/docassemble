#! /bin/bash

su -c   "source \"${DA_ACTIVATE}\" && python -m docassemble.base.read_config \"${DA_CONFIG_FILE}\" docassemble"

export LOGDIRECTORY="${LOGDIRECTORY:-${DA_ROOT}/log}"