#! /bin/bash

if [ ! -f "${DA_ROOT}/certs/apache.key" ] && [ -f "${DA_ROOT}/certs/apache.key.orig" ]; then
    mv "${DA_ROOT}/certs/apache.key.orig" "${DA_ROOT}/certs/apache.key"
fi
if [ ! -f "${DA_ROOT}/certs/apache.crt" ] && [ -f "${DA_ROOT}/certs/apache.crt.orig" ]; then
    mv "${DA_ROOT}/certs/apache.crt.orig" "${DA_ROOT}/certs/apache.crt"
fi
if [ ! -f "${DA_ROOT}/certs/apache.ca.pem" ] && [ -f "${DA_ROOT}/certs/apache.ca.pem.orig" ]; then
    mv "${DA_ROOT}/certs/apache.ca.pem.orig" "${DA_ROOT}/certs/apache.ca.pem"
fi