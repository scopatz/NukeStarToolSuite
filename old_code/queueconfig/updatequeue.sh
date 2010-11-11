#!/bin/bash

QDIR=/var/spool/pbs/server_priv/queues
QLIST="default overlord long medium short"

echo Deleting old queues
for x in $QLIST
do
	rm $QDIR/$x
done

echo Shutting down Torque
qterm
killall pbs_server

pause 5

echo Restarting Torque
pbs_server

echo Piping queue information to Torque Server
cat qconfig | qmgr

pause 2

for x in $QLIST
do
	if [ ! -f $QDIR/$x ]; then
	  echo Did not find queues in server settings, something may be wrong
	  exit 1
	fi
done

echo Success
exit 0
