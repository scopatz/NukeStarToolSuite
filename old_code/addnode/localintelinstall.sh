#!/bin/sh

VERSION=10.1.025

# install RPM package manager
apt-get install libnspr4-0d libnss3-1d librpm0 librpmbuild0 librpmio0 rpm
apt-get install alien build-essential cvs debhelper dpkg-dev fakeroot gettext html2text intltool-debian libcroco3 libmail-sendmail-perl libsys-hostname-long-perl po-debconf update-inetd

sleep 5

# decompress files
tar -xzf l_fc_p_$VERSION.tar.gz 
tar -xzf l_cc_p_$VERSION.tar.gz 

sleep 5

# install 32-bit compiler tools
apt-get install ia32-libs lib32asound2 lib32bz2-1.0 lib32gcc1 lib32ncurses5 lib32stdc++6 lib32v4l-0 lib32z1 libasound2 libc6-i386 libv4l-0
if [ ! -f /usr/lib32/libstdc++.so.5 ]; then 
	cd /tmp/
	wget http://security.ubuntu.com/ubuntu/pool/universe/i/ia32-libs/ia32-libs_2.7ubuntu6.1_amd64.deb
	dpkg-deb -x ia32-libs_2.7ubuntu6.1_amd64.deb ia32-libs
	sudo cp ia32-libs/usr/lib32/libstdc++.so.5.0.7 /usr/lib32/
	cd /usr/lib32
	sudo ln -s libstdc++.so.5.0.7 libstdc++.so.5
fi

sleep 5
echo "searching for license file in home directory"
if [ $(ls $HOME | grep -c intel.lic) -eq 0 ]; then
	echo "cannot find license file!"
	exit 1
else
	echo "I found intel.lic"
fi

INTEL_LICENSE_FILE=/root/intel.lic

# install c++ compiler
cd /root/l_cc_p_$VERSION/data
./install_cc.sh --run --silent /root/intelCCconfig.ini

sleep 5 

# install fortran compiler
cd /root/l_fc_p_$VERSION/data
./install_fc.sh --run --silent /root/intelFCconfig.ini

# add path variable
#if [ $(echo $PATH | grep -c "/opt/intel") -eq 0 ]; then
	#echo "export PATH=\$PATH:/opt/intel/cce/$VERSION/bin:/opt/intel/fce/$VERSION/bin" >> ~/.bashrc
#fi
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

# update dynamic library
ldconfig

# cleanup
rm -r /root/l_cc_p_10.1.025
rm -r /root/l_fc_p_10.1.025
rm /root/intel.lic
rm /root/intelCCconfig.ini
rm /root/intelFCconfig.ini
rm /root/l_cc_p_10.1.025.tar.gz
rm /root/l_fc_p_10.1.025.tar.gz


exit

