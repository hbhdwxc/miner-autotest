#!/bin/bash
# Author March 2018 xuzhenxing <xuzhenxing@canaan-creative.com>

# Index initial
idx=0

# Get raspberry IP address
IP=`cat ip-freq-voltlevel-devid.config | sed -n '2p' | awk '{ print $1 }'`
./scp-login.exp $IP 0
sleep 3

# Config /etc/config/cgminer and restart cgminer, Get Miner debug logs
for tmp in `cat ip-freq-voltlevel-devid.config | awk 'NR > 7'`;
do

# Get freq, voltage-level
let idx=idx+1
if [ $idx -eq 1 ];then
    freq_value=$tmp
    continue
fi

if [ $idx -eq 2 ];then
    volt_level_value=$tmp
fi

let idx=0
echo "freq  = $freq_value, voltage-level = $volt_level_value"

# Config freq voltage-level
more_options=`cat cgminer | grep more_options`
miner_type=`cat ip-freq-voltlevel-devid.config | sed -n '2p' | awk '{ print $2 }'`
if [ $miner_type == "avalon8" ]; then
    sed -i "s/$more_options/	option more_options '--avalon8-freq $freq_value --avalon8-voltage-level $volt_level_value'/g" cgminer
elif [ $miner_type == "avalon9" ]; then
    sed -i "s/$more_options/	option more_options '--avalon9-freq $freq_value --avalon9-voltage-level $volt_level_value'/g" cgminer
else
    echo "avalon type error"
    rm cgminer
    exit
fi

# Cp cgminer to /etc/config
./scp-login.exp $IP 1
sleep 3

# CGMiner restart
./ssh-login.exp $IP /etc/init.d/cgminer restart
sleep 180

# Read AvalonMiner Power
./read-power.py

# SSH no password
./ssh-login.exp $IP cgminer-api estats estats.log > /dev/null
./ssh-login.exp $IP cgminer-api edevs edevs.log > /dev/null
./ssh-login.exp $IP cgminer-api summary summary.log > /dev/null

# Read CGMiner Log
./read-debuglog.sh $freq_value $volt_level_value

done

# Remove cgminer file
rm cgminer
