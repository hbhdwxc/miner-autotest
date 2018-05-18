#!/bin/bash

IP=`cat ip-freq-voltlevel.config | grep 'Power-IP' | awk '{ print $2 }'`

# Remote run read-power.py
./ssh-login.exp ${IP} python /root/read-power.py > /dev/null

# Remote copy Power file
./scp-login.exp $IP 2 > /dev/null
