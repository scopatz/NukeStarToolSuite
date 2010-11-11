#!/bin/bash

TVER=2.4.8
MVER=3.3

if [ ! -d torque-$TVER ]; then
	echo "    Installing Torque on the host server"
	# remove old installations
	rm -r /var/spool/pbs

	# decompress soure code
	tar -xzf torque-$TVER.tar.gz
	cd torque-$TVER
	./configure --with-default-server=nukestar01 --with-server-home=/var/spool/pbs --with-rcp=scp
	make
	make install

	# copy nodes file
	cp ../nodes /var/spool/pbs/server_priv/.

	# add libraries
	apt-get install autotools-dev libltdl-dev libltdl7 libtool
	libtool --finish /usr/local/lib

	# start pbs mom
	pbs_mom

	# start pbs server
	pbs_server -t create

	# create queues
	cd /root/queueconfig
	sh updatequeue.sh
	cd /root/addnode/torque-$TVER

	# make install packages for worker nodes
	make packages
fi

if [ ! -d maui-$MVER ]; then
	echo "    Installing MAUI on the host server"
	tar -xzf maui-$MVER.tar.gz
	cd maui-$MVER
	./configure --with-pbs --with-spooldir=/var/spool/maui
	make
	make install
	sed -i 's/RMCFG[NUKESTAR01] TYPE=PBS@RMNMHOST/RMCFG[nukestar01] TYPE=PBS/g' /var/spool/maui/maui.cfg
	maui
fi

cd /root/addnode/torque-$TVER
for X in $(cat ../nodes | cut -d\  -f1)
do
	if [ $(ssh $X ps x | grep pbs_mom | grep -c -v grep) -eq 0 ]; then
		echo "   Installing torque on computation node" $X
		pause 2
		scp torque-package-mom-linux-x86_64.sh $X:/root/.
		ssh $X /root/torque-package-mom-linux-x86_64.sh --install

		ssh $X apt-get install autotools-dev libltdl-dev libltdl7 libtool
		ssh $X libtool --finish /usr/local/lib

		scp /var/spool/pbs/server_name $X:/var/spool/pbs/.
		ssh $X pbs_mom
	fi
done

echo "   Placing startup scripts in init.d"
cd /root/addnode
cp torque-node /etc/init.d/.
cp torque-server /etc/init.d/.
update-rc.d torque-node defaults
update-rc.d torque-server defaults


echo "   Done installing torque"
exit
