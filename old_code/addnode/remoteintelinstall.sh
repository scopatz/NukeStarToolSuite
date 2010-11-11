#!/bin/sh

REQFILES="intelCCconfig.ini intelFCconfig.ini intel.lic l_cc_p_10.1.025.tar.gz l_fc_p_10.1.025.tar.gz intelcompilers.conf localintelinstall.sh"
NAME=$1

for X in $REQFILES
do
	if [ ! -f $X ]; then
		echo "I need the file $X to be in the current directory"
		exit 1
	fi
done

# install intel compiler
echo "Installing INTEL Compilers on remote machine"
scp l_cc_p_10.1.025.tar.gz root@$NAME:/root/.
scp l_fc_p_10.1.025.tar.gz root@$NAME:/root/.
scp localintelinstall.sh root@$NAME:/root/.
scp intelCCconfig.ini root@$NAME:/root/.
scp intelFCconfig.ini root@$NAME:/root/.
scp intel.lic root@$NAME:/root/.
scp intelcompilers.conf root@$NAME:/etc/ld.so.conf.d/.
ssh root@$NAME exec /root/localintelinstall.sh
echo "Done installing INTEL compilers on remote machine"
