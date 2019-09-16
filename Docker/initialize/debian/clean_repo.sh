#! /bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get clean &> /dev/null
apt-get -q -y update &> /dev/null