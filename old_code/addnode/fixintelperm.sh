#!/bin/sh
VERSION=10.1.025
rm /usr/bin/icc
rm /usr/bin/icpc
rm /usr/bin/ifort
# add symbolic links 
if [ ! -f /usr/sbin/icc ]; then
	echo "creating symbolic link for icc in /usr/sbin/"
	ln -s /opt/intel/cce/$VERSION/bin/icc /usr/sbin/icc
fi
if [ ! -f /usr/sbin/icpc ]; then
	echo "creating symbolic link for icpc in /usr/sbin/"
	ln -s /opt/intel/cce/$VERSION/bin/icpc /usr/sbin/icpc
fi
if [ ! -f /usr/sbin/ifort ]; then
	echo "creating symbolic link for ifort in /usr/sbin/"
	ln -s /opt/intel/fce/$VERSION/bin/ifort /usr/sbin/ifort
fi

# change permissions so only root can use compiler, we onyl hav ea single user license
chmod 700 /opt/intel/cc/$VERSION/bin/*
chmod 700 /opt/intel/cce/$VERSION/bin/*
chmod 700 /opt/intel/fc/$VERSION/bin/*
chmod 700 /opt/intel/fce/$VERSION/bin/*


