#!/bin/bash
# Author March 2018 xuzhenxing <xuzhenxing@canaan-creative.com>

# Read AvalonMiner Power
./read-power.py

# SSH no password
IP=`cat ip-freq-voltlevel-devid.config | sed -n '2p' | awk '{ print $1 }'`
./ssh-login.exp $IP cgminer-api estats estats.log > /dev/null
./ssh-login.exp $IP cgminer-api edevs edevs.log > /dev/null
./ssh-login.exp $IP cgminer-api summary summary.log > /dev/null

# Read CGMiner Log
./read-debuglog.sh
