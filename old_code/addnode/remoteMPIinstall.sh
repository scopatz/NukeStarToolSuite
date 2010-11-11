#!/bin/sh

REQFILES="localMPIinstall.sh openmpi-1.4.1.tar.gz"
NAME=$1


for X in $REQFILES
do
	if [ ! -f $X ]; then
		echo "I need the file $X to be in the current directory"
		exit 1
	fi
done


echo "Installing openMPI on remote machine"
scp openmpi-1.4.1.tar.gz root@$NAME:/root/.
scp localMPIinstall.sh root@$NAME:/root/.
ssh root@$NAME exec /root/localMPIinstall.sh
echo "Done installing openMPI on remote machine"

