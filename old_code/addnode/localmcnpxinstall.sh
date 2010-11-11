#!/bin/sh

MCNPXDATADIR=/usr/share/mcnpxlib
MCNPX26DIR=/usr/share/mcnpxv260
MCNPX27DIR=/usr/share/mcnpxv27c

# remove existing installation notes
rm install.log &> /dev/null


# get into root direcotry
echo "    Entering directory /root"
cd /root


# install gfortran and x11 dev header files
echo "    Installing necessary libraries and compilers"
apt-get install binutils gcc gcc-4.4 gfortran gfortran-4.4 libc-dev-bin libc6-dev libgfortran3 libgomp1 libpthread-stubs0 libpthread-stubs0-dev libx11-dev libxau-dev libxcb1-dev libxdmcp-dev linux-libc-dev x11proto-core-dev x11proto-input-dev x11proto-kb-dev xtrans-dev


# make a link to f90
ln -s /usr/bin/f95 /usr/bin/f90 


# make directory in /usr/bin
echo "    Removing existing MCNPX directories"
rm -r $MCNPXDATADIR
rm -r $MCNPX26DIR 
rm -r $MCNPX26DIR/bin 
rm -r $MCNPX26DIR/lib 
rm -r $MCNPX27DIR 
rm -r $MCNPX27DIR/bin 
rm -r $MCNPX27DIR/lib 

echo "    Creating MCNPX directories"
mkdir $MCNPXDATADIR
mkdir $MCNPX26DIR 
mkdir $MCNPX26DIR/bin 
mkdir $MCNPX26DIR/lib 
mkdir $MCNPX27DIR 
mkdir $MCNPX27DIR/bin 
mkdir $MCNPX27DIR/lib 


# unpack libraries to lib
echo "    Unpacking MCNPX data libraries to" $MCNPXDATADIR
tar -xzf mcnpxdata.tar.gz --directory=$MCNPXDATADIR
echo "    Linking data libraries"
ln -s $MCNPXDATADIR/* $MCNPX26DIR/lib/.
ln -s $MCNPXDATADIR/* $MCNPX27DIR/lib/.


# unpack mcnpx
echo "    Unpacking MCNPX source code"
rm -r v260 
tar -xzf v260.tar.gz  
rm -r v27c 
tar -xzf v27c.tar.gz  

sleep 5

# change into source direcotry
echo "    Entering directory v260"
cd /root/v260  
# configure
echo "    Configuring install"
./configure --prefix=$MCNPX26DIR --with-CC=mpicc --with-FC=mpif90 --with-FOPT="-O3" --with-COPT="-O3" --with-MPILIB --x-include=/usr/lib --x-libraries=/usr/lib --with-FFLAGS="-DUNIX=1 -DLINUX=1" --with-CFLAGS="-DUNIX=1 -DLINUX=1" --with-LDFLAGS="-lirc"
# delete a line  i have no idea what it does besides causing an error
find . -name "Makefile.h" -exec sed -i "/PARALIB/d" {} \;  
# another random fix
find . -name "Makefile.h" -exec sed -i "s/-lutil\"/ /g" {} \;
# compile
echo "    Compiling MCNPX"
make  
sleep 5
# install
echo "    Installing MCNPX to" $MCNPX26DIR
make install  

sleep 5

# change into source direcotry
echo "    Entering directory v27c"
cd /root/v27c  
# configure
echo "    Configuring install"
./configure --prefix=$MCNPX27DIR --with-CC=mpicc --with-FC=mpif90 --with-FOPT="-O3" --with-COPT="-O3" --with-MPILIB --x-include=/usr/lib --x-libraries=/usr/lib --with-FFLAGS="-DUNIX=1 -DLINUX=1" --with-CFLAGS="-DUNIX=1 -DLINUX=1"  --with-LDFLAGS="-lirc"
# delete a line  i have no idea what it does besides causing an error
find . -name "Makefile.h" -exec sed -i "/PARALIB/d" {} \;  
# another random fix
find . -name "Makefile.h" -exec sed -i "s/-lutil\"/ /g" {} \;
# compile
echo "    Compiling MCNPX"
make  
sleep 5
# install
echo "    Installing MCNPX to" $MCNPX27DIR
make install  
sleep 5

# check to make sure compile and install went okay
if [ ! -f /usr/share/mcnpxv260/bin/mcnpx ]; then
	echo "    ERROR: something went wrong"
	exit 1
fi

# rename mcnpx
mv $MCNPX26DIR/bin/mcnpx $MCNPX26DIR/bin/mcnpx260  
mv $MCNPX27DIR/bin/mcnpx $MCNPX27DIR/bin/mcnpx27c  


# add environment variables to bashrc
echo "    Adding environmental variables"
if [ $(echo $PATH | grep -c $MCNPX26DIR) -eq 0 ]; then
	echo "export PATH=\$PATH:"$MCNPX26DIR"/bin" >>  /root/.bashrc
fi
if [ $(echo $PATH | grep -c $MCNPX27DIR) -eq 0 ]; then
	echo "export PATH=\$PATH:"$MCNPX27DIR"/bin" >>  /root/.bashrc
fi
if [ $(echo $DATAPATH | grep -c $MCNPXDATADIR) -eq 0 ]; then
	echo "export DATAPATH="$MCNPXDATADIR"" >> /root/.bashrc
fi


echo "    Adding mcnpx groups"
addgroup mcnpxdata
addgroup mcnpx27
addgroup mcnpx26
sleep 1
echo "    Changing permissions"

find $MCNPX27DIR -type d | xargs -i chmod 750 {} 
find $MCNPX27DIR -type f | xargs -i chmod 640 {} 
find $MCNPX27DIR/bin | xargs -i chmod 750 {} 
find $MCNPX27DIR | xargs -i chgrp mcnpx27 {} 

find $MCNPX26DIR -type d | xargs -i chmod 750 {} 
find $MCNPX26DIR -type f | xargs -i chmod 640 {} 
find $MCNPX26DIR/bin | xargs -i chmod 750 {} 
find $MCNPX26DIR | xargs -i chgrp mcnpx26 {} 

# the data directory permissions must come last
find $MCNPXDATADIR | xargs -i chgrp mcnpxdata {}
find $MCNPXDATADIR -type f | xargs -i chmod 640 {}
find $MCNPXDATADIR -type d | xargs -i chmod 750 {}


# get back into original directory
echo "    Getting back into /root directory"
cd /root

# delete source code -- we dont want a lot of machines sitting around with export controlled info
echo "    Cleaning up source files "
rm -r v260  
rm v260.tar.gz  
rm mcnpxdata.tar.gz  
rm -r v27c  
rm v27c.tar.gz  
rm localmcnpxinstall.sh 

echo "    Done installing, installation notes written to install.log"
echo "    Logging out..."
exit




