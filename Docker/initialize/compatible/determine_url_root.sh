#! /bin/bash

if [ "${USEHTTPS:-false}" == "false" ] && [ "${BEHINDHTTPSLOADBALANCER:-false}" == "false" ]; then
    URLROOT="http:\\/\\/"
else
    URLROOT="https:\\/\\/"
fi