#! /bin/bash


if pg_isready -q --dbname=$DBNAME --host=$DBHOST --port=$DBPORT; then
    export PGRUNNING=true
else
    export PGRUNNING=false
fi