#! /bin/bash


time su -c "source \"${DA_ACTIVATE}\" && python -m docassemble.webapp.register \"${DA_CONFIG_FILE}\"" docassemble