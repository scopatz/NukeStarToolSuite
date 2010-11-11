#!/bin/sh

echo "Installing verb libs and c++ compiler"
apt-get install libibverbs1 libibverbs-dev g++ g++-4.4 libstdc++6-4.4-dev torque-dev libtorque2

echo "Unzipping openMPI source code"
tar -xzf openmpi-1.4.1.tar.gz  

echo "Compiling openMPI"
cd openmpi-1.4.1

echo "path is " $PATH
echo "using fortran compiler" $(which ifort)
echo "using c compiler" $(which icc)


# add neccessary environmental variables
#export PATH=$PATH:/opt/intel/cce/10.1.025/bin:/opt/intel/fce/10.1.025/bin
#export LD_LIBRARY_PATH=/opt/intel/cce/10.1.025/lib:/opt/intel/fce/10.1.025/lib
#export CFLAGS=-O3
#export FFLAGS=-O3
export LDFLAGS=-lirc
export FC=ifort
export CC=icc
export F77=ifort
export CXX=icpc


./configure --with-tm --enable-heterogeneous 

make 

make install 

echo "Done compiling openMPI, cleaning up files"

cd ..
rm -r openmpi-1.4.1
#rm openmpi-1.4.1.tar.gz

echo "Processing ldconfig"
ldconfig

echo "Exiting remote machine"

exit

