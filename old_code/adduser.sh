#!/bin/bash

# beginning of script to add user

# make user
adduser $1

# add user to mcnpx group
read -p "Is the user a Citizen of the United States of America and authorized by RSICC to use MCNPX version 2.6.0 (y/n)?"
[ "$REPLY" == "y" ] || adduser $1 mcnpx

# given them appropriate environmental variables
echo "# user added envrionmental variables" >> /home/$1/.bashrc
echo "export HOSTLIST=/usr/share/hostlist" >> /home/$1/.bashrc
echo "export PATH=$PATH:/usr/share/mcnpxv260/bin" >> /home/$1/.bashrc
echo "export DATAPATH=/usr/share/mcnpxv260/lib" >> /home/$1/.bashrc


