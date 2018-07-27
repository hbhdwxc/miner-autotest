#!/bin/bash
file=power.csv
for i in `cat $2/$3`
do 
	str=$i',' 
	echo $str | awk '{ printf $1 }' >> $2/$file 
done  
awk '{for(n=1;n<=NF;++n)a[n]+=$n}END{for(n=1;n<=NF;++n)$n=a[n]/NR;print}' $2/$3 >> $2/$file
#cat $2/temp.txt | sed 's/.$/\n/' >> $2/power.csv 


