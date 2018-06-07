#!/bin/bash
#
# Author March 2018 xuzhenxing <xuzhenxing@canaan-creative.com>
#

# Create result directory
[ -z $1 ] && exit
[ -z $2 ] && exit
CIP=$1
PIP=$2
dirip="result-"$CIP
mkdir $dirip

user=`who | awk '{ print $1 }'`
ssh-keygen -f "/home/$user/.ssh/known_hosts" -R $CIP > /dev/null
ssh-keygen -f "/home/$user/.ssh/known_hosts" -R $PIP > /dev/null

# Copy CGMiner configuration file
./scp-login.exp $CIP $dirip 0
sleep 3

# Create result.csv
echo "Freq,Volt-level,Vcore,GHSmm,Temp,TMax,WU,GHSav,Power,Power/GHSav,DH,DNA" > ./$dirip/miner-result.csv

# Config /etc/config/cgminer and restart cgminer, Get Miner debug logs
cat miner-options.config | grep avalon |  while read tmp
do
    more_options=`cat ./$dirip/cgminer | grep more_options`
    if [ "$more_options" == "" ]; then
        echo "option more_options" >> ./$dirip/cgminer
    fi

    more_options=`cat ./$dirip/cgminer | grep more_options`
    sed -i "s/$more_options/	option more_options '$tmp'/g" ./$dirip/cgminer

    # Cp cgminer to /etc/config
    ./scp-login.exp $CIP $dirip 1
    sleep 3

    # CGMiner restart
    ./ssh-login.exp $CIP /etc/init.d/cgminer restart
    sleep 30

    # Read AvalonMiner Power
    ./ssh-power.py $PIP
    sleep 1

    # Copy remote power file
    ./scp-login.exp $PIP $dirip 2 > /dev/null
    sleep 3

    # SSH no password
    ./ssh-login.exp $CIP cgminer-api "debug\|D" > /dev/null
    sleep 1
    ./ssh-login.exp $CIP cgminer-api estats ./$dirip/estats.log > /dev/null
    ./ssh-login.exp $CIP cgminer-api edevs ./$dirip/edevs.log > /dev/null
    ./ssh-login.exp $CIP cgminer-api summary ./$dirip/summary.log > /dev/null

    # Read CGMiner Log
    ./debuglog.sh $tmp
done

more_options_flag=`cat miner-options.config | grep avalon`
# more options is null
if [ -z "${more_options_flag}" ]; then
    more_options=`cat ./$dirip/cgminer | grep more_options`
    tmp=`echo ${more_options#*more_options} | sed "s/'//g"`

    # Read AvalonMiner Power
    ./ssh-power.py $PIP
    sleep 1

    # Copy remote power file
    ./scp-login.exp $PIP $dirip 2 > /dev/null
    sleep 3

    # SSH no password
    ./ssh-login.exp $CIP cgminer-api estats ./$dirip/estats.log > /dev/null
    debug=`cat ./$dirip/estats.log | grep PVT`
    if [ -z $debug ]; then
        ./ssh-login.exp $CIP cgminer-api "debug\|D" > /dev/null
        sleep 1
        rm ./$dirip/estats.log
        ./ssh-login.exp $CIP cgminer-api estats ./$dirip/estats.log > /dev/null
    fi

    sleep 1
    ./ssh-login.exp $CIP cgminer-api edevs ./$dirip/edevs.log > /dev/null
    ./ssh-login.exp $CIP cgminer-api summary ./$dirip/summary.log > /dev/null

    # Read CGMiner Log
    ./debuglog.sh $tmp
fi

# Remove cgminer file
rm ./$dirip/cgminer
