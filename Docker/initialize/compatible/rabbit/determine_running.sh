#! /bin/bash

if rabbitmqctl status &> /dev/null; then
    RABBITMQRUNNING=true
else
    RABBITMQRUNNING=false
fi