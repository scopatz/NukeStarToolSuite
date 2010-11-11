#!/bin/bash


declare -a NAMES
declare -a IPS

names="nukestar03 nukestar05 nukestar08"
let N=3
# names="nukestar02 nukestar03 nukestar04 nukestar05 nukestar06 nukestar07 nukestar08"
# let N=7

let n=1
while [ $n -le $N ]
do
	NAMES[$n]=$(echo $names | cut -d\  -f$n)
	((n++))
done

let n=1
while [ $n -le $N ]
do
	echo "Installing openMPI on remote machine" ${NAMES[n]}
	scp openmpi-1.4.1.tar.gz root@${NAMES[n]}:/root/.
	scp localMPIinstall.sh root@${NAMES[n]}:/root/.
	ssh root@${NAMES[n]} exec /root/localMPIinstall.sh

	echo "Installing MCNPX on remote machine"

	# put mcnpx src and data
	echo "Copying MCNPX files to remote machine"
	tar -czf - localmcnpxinstall.sh mcnpxv260.tar.gz mcnpxdata.tar.gz | ssh root@${NAMES[n]} tar -xzf - -C /root/

	# executing install script on remote machine
	echo "Executing MCNPX install script on remote machine" 
	ssh root@${NAMES[n]} exec /root/localmcnpxinstall.sh

	((n++))
done


