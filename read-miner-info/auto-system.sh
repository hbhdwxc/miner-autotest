#!/bin/bash
# Author March 2018 xuzhenxing <xuzhenxing@canaan-creative.com>

# Get raspberry IP address
IP=`cat ip-freq-voltlevel-devid.config | sed -n '2p' | awk '{ print $1 }'`
./scp-login.exp $IP 0

cat ip-freq-voltlevel-devid.config | awk 'NR > 7' > test.config

# Config freq voltage-level
while read FREQ VOLT_LEVEL;
do
echo $FREQ $VOLT_LEVEL

freq=`cat cgminer | grep more_options`
sed -i "s/$freq/	option more_options '--avalon8-freq $FREQ'/g" cgminer

volt_offset=`cat cgminer | grep "voltage_level_offset"`
sed -i "s/$volt_offset/	option voltage_level_offset '$VOLT_LEVEL'/g" cgminer

./scp-login.exp $IP 1
sleep 10

# CGMiner restart
./ssh-login.exp $IP /etc/init.d/cgminer restart
sleep 60

# Read AvalonMiner Power
./read-power.py

# SSH no password
./ssh-login.exp $IP cgminer-api estats estats.log > /dev/null
./ssh-login.exp $IP cgminer-api edevs edevs.log > /dev/null
./ssh-login.exp $IP cgminer-api summary summary.log > /dev/null

# Read CGMiner Log
./read-debuglog.sh

done < test.config

# Remove cgminer file
rm cgminer
