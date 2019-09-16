#! /bin/bash
if hash redis-cli 2>/dev/null; 
then 
        if redis-cli ping  &> /dev/null 
        then
            REDISRUNNING=true
        else
            REDISRUNNING=false
        fi
else
        REDISRUNNING=false
fi