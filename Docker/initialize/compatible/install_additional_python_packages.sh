#! /bin/bash

if [ -n "$PYTHONPACKAGES" ]; then
    for PACKAGE in "${PYTHONPACKAGES[@]}"; do
        su -c "source \"${DA_ACTIVATE}\" && pip install $PACKAGE"  www-data
    done
fi
