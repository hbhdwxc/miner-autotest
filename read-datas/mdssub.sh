#!/bin/bash
#
# Author March 2018 Zhenxing Xu <xuzhenxing@canaan-creative.com>
#

[ -z $1 ] && exit
time=$1

# Create result directory
[ -z $2 ] && exit
[ -z $3 ] && exit
CIP=$2
PIP=$3
dirip="result-"$CIP
mkdir $dirip

# Copy CGMiner configuration file
./scp-login.exp $CIP $dirip 0
sleep 3

# Create result.csv
echo "Volt-level,Temp,TMax,WU,GHSav,DH,DNA" >> ./$dirip/miner-result.csv

# Config /etc/config/cgminer and restart cgminer, Get Miner debug logs
cat miner-options.conf | grep avalon |  while read tmp
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

    for i in `seq 1 8`
    do
        sleep $time

        # Read AvalonMiner Power
        ./ssh-power.py $PIP
        sleep 1

        # Copy remote power file
        ./scp-login.exp $PIP $dirip 2 > /dev/null
        sleep 3

        #conver line to column
        ./line_to_col.sh $CIP $dirip CGMiner_Power.log

        ./ssh-login.exp $CIP cgminer-api estats ./$dirip/estats.log > /dev/null
        sleep 1

        # Read CGMiner Log
        ./debuglog.sh $CIP $tmp
    done
    cat ./$dirip/miner-result.csv | while read line 
    do
        echo $line >> ./$dirip/miner-result-all.csv
    done
done

# Remove cgminer file
rm ./$dirip/cgminer
