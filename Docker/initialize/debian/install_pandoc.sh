#! /bin/bash

pandoc --help &> /dev/null || apt-get -q -y install pandoc

PANDOC_VERSION=`pandoc --version | head -n1`

if [ "${PANDOC_VERSION}" != "pandoc 2.7" ]; then
   cd /tmp \
   && dpkg -i /tmp/docassemble/installers/pandoc-2.7-1-amd64.deb \
   && rm pandoc-2.7-1-amd64.deb
fi