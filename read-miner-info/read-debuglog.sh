#!/bin/bash

IP=`cat ip-freq-voltlevel-devid.config | sed -n '2p' | awk '{ print $1 }'`
DATE=`date +%Y%m%d%H%M`
dirname=$IP"-"$DATE"-"$2"-"$4"-"$6"-"$8
mkdir $dirname

cat estats.log  | grep "\[MM ID" > ./$dirname/CGMiner_Debug.log
cat edevs.log | grep -v Reply  > ./$dirname/CGMiner_Edevs.log
cat summary.log | grep -v Reply  > ./$dirname/CGMiner_Summary.log

rm estats.log edevs.log summary.log
mv CGMiner_Power.log ./$dirname
cd ./$dirname

for i in CGMiner_Debug.log
do
    cat $i | sed 's/] /\]\n/g' | grep GHSmm | sed 's/GHSmm\[//g' | sed 's/\]//g' > $i.GHSmm
    cat $i | sed 's/] /\]\n/g' | grep Temp  | sed 's/Temp\[//g'  | sed 's/\]//g' > $i.Temp
    cat $i | sed 's/] /\]\n/g' | grep TMax  | sed 's/TMax\[//g'  | sed 's/\]//g' > $i.TMax
    cat $i | sed 's/] /\]\n/g' | grep WU    | sed 's/WU\[//g'    | sed 's/\]//g' > $i.WU

    # According to WU value, calculate GHSav.
    # Formula: ghsav = WU / 60 * 2^32 /10^9
    cat $i.WU | awk '{printf ("%.2f\n", ($1/60*2^32/10^9))}' > $i.GHSav

    Power=CGMiner_Power.log
    Result=Results_$dirname

    # Power ratio
    paste $i.GHSav $Power | awk '{printf ("%.3f\n", ($2/$1))}' > ph.log

    echo "GHSmm,Temp,TMax,WU,GHSav,Power,PE" > ${Result#.log}.csv
    paste -d, $i.GHSmm $i.Temp $i.TMax $i.WU $i.GHSav $Power ph.log >> ${Result#.log}.csv

    rm -rf $i.GHSmm $i.Temp $i.TMax $i.WU $i.GHSav ph.log

    cd ..
    mv ./$dirname ./result*
done
