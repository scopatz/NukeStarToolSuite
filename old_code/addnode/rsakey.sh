#!/bin/sh


echo "    Checking for rsa key on this computer"
if [ ! -f ~/.ssh/id_rsa ]; then
	echo "    Need to generate key, please accept all the defaults"
	ssh-keygen -t rsa
fi

echo "    Adding nukestar01 to known hosts"
echo "192.168.1.2 nukestar01" >> /etc/hosts

echo "    Copying key back to head node (I will need the root password)"
ssh-copy-id root@192.168.1.2

