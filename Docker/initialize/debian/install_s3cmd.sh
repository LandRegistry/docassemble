#! /bin/bash

if [ ! -x s3cmd ]; then
    apt-get -q -y install s3cmd
fi