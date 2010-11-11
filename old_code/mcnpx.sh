MPIRUN=`which mpirun`
MCNPX=`which mcnpx260`

${MPIRUN} \
-np 24 \
--hostfile $HOSTLIST \
${MCNPX} i=test.i n=test. 

