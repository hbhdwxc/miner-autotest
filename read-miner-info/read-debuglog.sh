#!/bin/bash

IP_DIR=`cat ip-freq-voltlevel.config | awk 'NR > 1 { print $1 }'`
DATE=`date +%Y%m%d%H%M`
dirname=${IP_DIR}"-"${DATE}
mkdir $dirname

cat ip-freq-voltlevel.config | awk 'NR > 1' | while read IP FREQ VOLT_LEVEL
do
	cat estats.log  | grep "\[MM ID" > ./$dirname/"CGMiner_Debug_"$IP"_"$FREQ"M_Level"$VOLT_LEVEL".log"
	cat edevs.log | grep -v Reply  > ./$dirname/"CGMiner_Edevs_"$IP"_"$FREQ"M_Level"$VOLT_LEVEL".log"
	cat summary.log | grep -v Reply  > ./$dirname/"CGMiner_Summy_"$IP"_"$FREQ"M_Level"$VOLT_LEVEL".log"

	echo $IP $FREQ $VOLT_LEVEL
done

rm estats.log edevs.log summary.log
mv avalon-miner-power.log ./$dirname
cd ./$dirname

for i in CGMiner_Debug_*.log
do
	cat $i | sed 's/\] /\]\n/g' | grep GHSmm| sed 's/GHSmm\[//g' | sed 's/\]//g' > $i.GHSmm
	cat $i | sed 's/\] /\]\n/g' | grep Temp | sed 's/Temp\[//g'  | sed 's/\]//g' > $i.Temp
	cat $i | sed 's/\] /\]\n/g' | grep TMax | sed 's/TMax\[//g'  | sed 's/\]//g' > $i.TMax
	cat $i | sed 's/\] /\]\n/g' | grep WU   | sed 's/WU\[//g'    | sed 's/\]//g' > $i.WU

	# According to WU value, calculate GHSav.
	# Formula: ghsav = WU / 60 * 2^32 /10^9
	cat $i.WU | awk '{printf ("%.2f\n", ($1/60*2^32/10^9))}' > $i.GHSav

	# ${i#*}: before delete assign string
	Power=avalon-miner-power.log
	Result=Results_${i#*CGMiner_}

	# Power ratio
	paste $i.GHSav $Power | awk '{printf ("%.3f\n", ($2/$1))}' > ph.log

	echo "GHSmm,Temp,TMax,WU,GHSav,Power,PE" > ${Result#.log}.csv
	paste -d, $i.GHSmm $i.Temp $i.TMax $i.WU $i.GHSav $Power ph.log >> ${Result#.log}.csv

	rm -rf $i.GHSmm $i.Temp $i.TMax $i.WU $i.GHSav ph.log
done
