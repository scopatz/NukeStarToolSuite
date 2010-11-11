#!/bin/sh

REQFILES="v27c.tar.gz v260.tar.gz mcnpxdata.tar.gz localmcnpxinstall.sh"
NAME=$1


for X in $REQFILES
do
	if [ ! -f $X ]; then
		echo "I need the file $X to be in the current directory"
		exit 1
	fi
done


echo "Installing MCNPX on remote machine"
# put mcnpx src and data
echo "Copying MCNPX files to remote machine"
tar -czf - localmcnpxinstall.sh v260.tar.gz v27c.tar.gz mcnpxdata.tar.gz | ssh root@$NAME tar -xzf - -C /root/

# executing install script on remote machine
echo "Executing MCNPX install script on remote machine" 
ssh root@$NAME exec /root/localmcnpxinstall.sh
echo "Done with MCNPX install on remote machine"



