#!/bin/bash

# command to count how many processes are available
ps aux | grep pbs_mom | grep -vc grep

# check if pbs_mom is running
if [ $(ps aux | grep pbs_mom | grep -vc grep) -eq 0 ]; then
  echo "    starting pbs_mom"
  pbs_mom
fi
pause 2
if [ $(ps aux | grep pbs_server | grep -vc grep) -eq 0 ]; then
  echo "    starting pbs_server"
  pbs_server
fi
pause 2
if [ $(ps aux | grep maui | grep -vc grep) -eq 0 ]; then
  echo "    starting maui"
  maui
fi
pause 2

for X in $(cat /var/spool/pbs/server_priv/nodes | cut -d\  -f1)
do
	echo "starting pbs_mom on node" $X
	ssh $X pbs_mom
done

echo "finished"
