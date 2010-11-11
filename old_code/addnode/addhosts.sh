#!/bin/bash

let N=7

declare -a NAMES
declare -a IPS

ips="192.168.1.3 192.168.1.6 192.168.1.4 192.168.1.5 192.168.1.9 192.168.1.7 192.168.1.100"
names="nukestar02 nukestar03 nukestar04 nukestar05 nukestar06 nukestar07 nukestar08"

let n=1
while [ $n -le $N ]
do
	NAMES[$n]=$(echo $names | cut -d\  -f$n)
	IPS[$n]=$(echo $ips | cut -d\  -f$n)
	((n++))
done

let n=1
while [ $n -le $N ]
do
	echo "logging into" ${NAMES[n]} "to add hosts"
	scp localaddhosts.sh root@${IPS[n]}:/root/.
	ssh root@${IPS[n]} /root/./localaddhosts.sh
	((n++))
	echo "done"
done


