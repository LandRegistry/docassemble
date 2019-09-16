#! /bin/bash


if [ ! -f "${DA_ROOT}/certs/exim.key" ] && [ -f "${DA_ROOT}/certs/exim.key.orig" ]; then
    mv "${DA_ROOT}/certs/exim.key.orig" "${DA_ROOT}/certs/exim.key"
fi
if [ ! -f "${DA_ROOT}/certs/exim.crt" ] && [ -f "${DA_ROOT}/certs/exim.crt.orig" ]; then
    mv "${DA_ROOT}/certs/exim.crt.orig" "${DA_ROOT}/certs/exim.crt"
fi