#!/bin/sh

REQFILES="remoteintelinstall.sh remotepbsinstall.sh remoteMPIinstall.sh remotemcnpxinstall.sh"

if [ $# -eq 1 ]; then
	if [ $(grep -c $1 /etc/hosts) -eq 0 ]; then
		echo "I did not find the first argument in /etc/hosts, therefore I need two arguments:"
		echo "          ip address of a nukestar, followed by its computer name"
		exit 1
	else
		NAME=$1
	fi
else
	IP=$1
	NAME=$2
	if [ $(grep -c $NAME /etc/hosts) -eq 0 ]; then
		# add host
		echo "Adding $NAME to known hosts"
		echo "$IP $NAME" >> /etc/hosts
	fi
	
	if [ $(grep -c $NAME /var/lib/torque/server_priv/nodes) -eq 0]; then
		# add slave to pbs node
		echo "Adding $2 as a slave node"
		echo "$2 np=1 Slave$2Description" >> /var/lib/torque/server_priv/nodes
	fi

	if [ $(grep -c $NAME /usr/share/hostlist) -eq 0]; then
		# add slave to mpi node
		echo "adding $2 to MPI node"
		# the slots and max-slots is the number of cpus on the computer, this
		# is hard-coded in as 1 right now, but should be made as a variable
		echo "$2 slots=1 max-slots=1" >> /usr/share/hostlist
	fi
fi


for X in $REQFILES
do
	if [ ! -f $X ]; then
		echo "I need the file $X to be in the current directory"
		exit 1
	fi
done


# install intel compiler
./remoteintelinstall.sh $NAME

# install pbs scheduler
./remotepbsinstall.sh $NAME

# install MPI
./remoteMPIinstall.sh $NAME

# install mcnpx
./remotemcnpxinstall.sh $NAME



pause 5

echo "Restarting pbs_server"
qterm -t quick
pbs_server

# done
echo " "
echo "Done with configuration"
echo "    edit  /var/lib/torque/server_priv/nodes  to complete the description and # of processors for $2"
echo "          /usr/share/hostlist                to complete # of processors for $2"
echo " "
echo " To reflect changes, log out of nukestar01, log back in"
echo "    then do"
echo "       qterm -t quick"
echo "       pbs_server"
echo "    check if all nodes are free using"
echo "       pbsnodes -a"
