#!/bin/bash


declare -a NAMES
declare -a IPS

ips="192.168.1.2 192.168.1.3 192.168.1.6 192.168.1.4 192.168.1.5 192.168.1.9 192.168.1.7 192.168.1.100"

names="nukestar01 nukestar02 nukestar03 nukestar04 nukestar05 nukestar06 nukestar07 nukestar08"


let N=8

echo $ips
echo $names

let n=1
while [ $n -le $N ]
do
	NAMES[$n]=$(echo $names | cut -d\  -f$n)
	IPS[$n]=$(echo $ips | cut -d\  -f$n)
	((n++))
done

let n=1
while [ ${n} -le ${N} ]
do
	echo ${IPS[n]} ${NAMES[n]} >> /etc/hosts
	#echo ${IPS[n]} ${NAMES[n]}
	((n++))
done


