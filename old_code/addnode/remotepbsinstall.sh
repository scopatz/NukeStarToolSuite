#!/bin/sh

TVER=2.4.8
NAME=$1

if [ ! -d torque-$TVER ]; then
	echo "There is no torque installation directory (torque-"$TVER") try running pbsinstall.sh first"
	exit 1
fi




# put install script
echo "Installing Torque PBS Client on remote machine"
cd torque-$TVER
pause 2
scp torque-package-mom-linux-x86_64.sh $NAME:/root/.
ssh $NAME /root/torque-package-mom-linux-x86_64.sh --install

ssh $NAME apt-get install autotools-dev libltdl-dev libltdl7 libtool
ssh $NAME libtool --finish /usr/local/lib

scp /var/spool/pbs/server_name $NAME:/var/spool/pbs/.
ssh $NAME pbs_mom

cd ..
scp torque-node $NAME:/etc/init.d/.
ssh $NAME update-rc.d torque-node defaults








echo "Done with Torque install on remote machine"

