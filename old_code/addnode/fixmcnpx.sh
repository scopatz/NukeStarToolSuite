#!/bin/bash


declare -a NAMES

names="nukestar02 nukestar03 nukestar04 nukestar05 nukestar06 nukestar07 nukestar08"
let N=7
# names="nukestar01"
# let N=1

let n=1
while [ $n -le $N ]
do
	NAMES[$n]=$(echo $names | cut -d\  -f$n)
	((n++))
done

let n=1
while [ $n -le $N ]
do
	echo "Moving mcnpx files on remote machine" ${NAMES[n]}
	ssh ${NAMES[n]} mv /usr/bin/mcnpxv260 /usr/share/.
	echo "Adding mcnpx group"
	ssh ${NAMES[n]} addgroup mcnpx
	echo "Changing permissions"
	ssh ${NAMES[n]} find /usr/share/mcnpxv260 -type d | xargs -i chmod 750 {} 
	ssh ${NAMES[n]} find /usr/share/mcnpxv260 -type f | xargs -i chmod 640 {} 
	ssh ${NAMES[n]} find /usr/share/mcnpxv260/bin | xargs -i chmod 750 {} 
	ssh ${NAMES[n]} find /usr/share/mcnpxv260 | xargs -i chgrp mcnpx {} 
	


	((n++))
done


