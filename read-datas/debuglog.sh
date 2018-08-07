#!/bin/bash
#
# Author June 2018 Zhenxing Xu <xuzhenxing@canaan-creative.com>
#

IP=$1
dirip="result-"$IP
DATE=`date +%Y%m%d%H%M%S`
dirname=$IP"-"$DATE"-"$3
mkdir -p ./$dirip/$dirname

cat ./$dirip/estats.log  | grep "\[MM ID" > ./$dirip/$dirname/CGMiner_Debug.log

rm ./$dirip/estats.log
#mv ./$dirip/CGMiner_Power.log ./$dirip/$dirname
cd ./$dirip/$dirname

# Freq and voltage level options
vol_cnt=`cat CGMiner_Debug.log | grep "\[MM ID" | wc -l`
for i in `seq 1 $vol_cnt`
do
    echo "$3" >> voltage.log
done

for i in CGMiner_Debug.log
do
    cat $i | sed 's/] /\]\n/g' | grep Temp  | sed 's/Temp\[//g'  | sed 's/\]//g' > $i.Temp
    cat $i | sed 's/] /\]\n/g' | grep TMax  | sed 's/TMax\[//g'  | sed 's/\]//g' > $i.TMax
    cat $i | sed 's/] /\]\n/g' | grep WU    | sed 's/WU\[//g'    | sed 's/\]//g' > $i.WU
    cat $i | sed 's/] /\]\n/g' | grep DH    | sed 's/DH\[//g'    | sed 's/\]//g' | sed 's/\%//g' > $i.DH
    cat $i | sed 's/] /\]\n/g' | grep DNA   | sed 's/DNA\[//g'   | sed 's/\]//g' | cut -b 13- > $i.DNA

    # According to WU value, calculate GHSav.
    # Formula: ghsav = WU / 60 * 2^32 /10^9
    cat $i.WU | awk '{printf ("%.2f\n", ($1/60*2^32/10^9))}' > $i.GHSav

    paste -d, voltage.log $i.Temp $i.TMax $i.WU $i.GHSav $i.DH $i.DNA > ../miner-result.csv

    # split DNA
    cnt=`cat ../miner-result.csv | wc -l`
    for i in `seq 1 $cnt`
    do
        str=`sed -n "${i}p" ../miner-result.csv`
        name=`echo ${str} | cut -d \, -f  7`
        echo $str >> ../miner-result-${name}.csv
    done

    rm -rf voltage.log $i.Temp $i.TMax $i.WU $i.GHSav $i.DH $i.DNA


    #add new file LotWaferID.csv to store the lotid && waferid info, backup for later use 
    cat $i | sed 's/] /\]\n/g' | grep DNA        | sed 's/DNA\[//g'         | sed 's/\]//g' | cut -b 13- > $i.DNA
    cat $i | sed 's/] /\]\n/g' | grep LotID0     | sed 's/LotID.*\[//g'     | sed 's/\]//g' > $i.lotid0
    cat $i | sed 's/] /\]\n/g' | grep LotID1     | sed 's/LotID.*\[//g'     | sed 's/\]//g' > $i.lotid1
    cat $i | sed 's/] /\]\n/g' | grep LotID2     | sed 's/LotID.*\[//g'     | sed 's/\]//g' > $i.lotid2
    cat $i | sed 's/] /\]\n/g' | grep LotID3     | sed 's/LotID.*\[//g'     | sed 's/\]//g' > $i.lotid3
    cat $i | sed 's/] /\]\n/g' | grep WaferID0   | sed 's/WaferID.*\[//g'   | sed 's/\]//g' > $i.waferid0
    cat $i | sed 's/] /\]\n/g' | grep WaferID1   | sed 's/WaferID.*\[//g'   | sed 's/\]//g' > $i.waferid1
    cat $i | sed 's/] /\]\n/g' | grep WaferID2   | sed 's/WaferID.*\[//g'   | sed 's/\]//g' > $i.waferid2
    cat $i | sed 's/] /\]\n/g' | grep WaferID3   | sed 's/WaferID.*\[//g'   | sed 's/\]//g' > $i.waferid3
    paste -d, $i.DNA $i.lotid0 $i.lotid1 $i.lotid2 $i.lotid3 $i.waferid0 $i.waferid1 $i.waferid2 $i.waferid3 > ./LotWaferID.csv

    rm -rf $i.DNA $i.lotid0 $i.lotid1 $i.lotid2 $i.lotid3 $i.waferid0 $i.waferid1 $i.waferid2 $i.waferid3

done
