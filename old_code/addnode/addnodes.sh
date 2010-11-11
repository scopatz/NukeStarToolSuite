#!/bin/bash

let N=4

declare -a NAMES
declare -a IPS

names="nukestar01 nukestar03 nukestar05 nukestar08"
#ips="192.168.1.3 192.168.1.6 192.168.1.9 192.168.1.7 192.168.1.100"

let n=1
while [ $n -le $N ]
do
	NAMES[$n]=$(echo $names | cut -d\  -f$n)
	#IPS[$n]=$(echo $ips | cut -d\  -f$n)
	((n++))
done

let n=1
while [ $n -le $N ]
do
	#sh addnode.sh ${IPS[n]} ${NAMES[n]}
	./addnode.sh ${NAMES[n]}
	((n++))
done


