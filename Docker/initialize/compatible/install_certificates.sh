#! /bin/bash


python -m docassemble.webapp.install_certs "${DA_CONFIG_FILE}" || exit 1