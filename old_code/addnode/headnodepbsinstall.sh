#!/bin/sh

echo "Installing Torque"
apt-get install libtorque2 gawk libcurses-perl tcl8.4 torque-base torque-client  torque-scheduler torque-mom torque-server


# mkdir /var/lib/torque/spool
chmod 1777 /var/lib/torque/spool /var/lib/torque/undelivered
mkdir /var/lib/torque/mom_priv
mkdir /var/lib/torque/server_priv
echo "nukestar01" > /var/lib/torque/server_name
echo "nukestar01 np=4" >> /var/lib/torque/server_priv/nodes


# create link because of bug
ln -s /etc/init.d/torque-scheduler /etc/init.d/torque-sched

# restart pbs_mom
killall pbs_mom
pbs_mom

# restart server
qterm -t quick
pbs_server

