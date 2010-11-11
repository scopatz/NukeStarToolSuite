#!/bin/bash
#
#~~~ NodeKeyGen ~~~
# A script that makes SSH rsa keys for all users on a machine.
# By Anthony Scopatz, scopatz@gmail.com, http://www.scopatz.com/
# Released under the GNU General Public License version 3.
#
# Dependencies:
# | - OpenSSL
#


#########################
### Color Definitions ###
#########################
C_MSG="\033[0;32m"	#Message Color
C_HNM="\033[1;35m"	#Hostname Color
C_USR="\033[1;36m"	#User Color
C_END="\033[0m"		#Return to Standard colors

############################################
### Finds the real users on this machine ###
############################################
let RealI=0
declare -a real_user
declare -a real_home

let i=0
real_user[$i]="root"
real_home[$i]="/root"
((i++))
((RealI++))

while read inputline 
do
	login="$(echo $inputline | cut -d: -f1)"
	homedir="$(echo $inputline | cut -d: -f6)"
	homebase="$( echo ${homedir} | cut -d/ -f2 )"
	if [ ${homebase} == "home" ]; then
	if [ ${login} != "syslog" ]; then
		real_user[$i]="${login}"
		real_home[$i]="${homedir}"
		((i++))
		((RealI++))
	fi
	fi
done < /etc/passwd

################################################
### Makes keys for all users on this machine ###
################################################

let i=0
while [ $i -lt $RealI ]
do
	ls ${real_home[i]}/.ssh > /dev/null 2>&1
	if [ $? -gt 0 ]; then
		su ${real_user[i]} -c "mkdir ${real_home[i]}/.ssh"
	fi
	ls ${real_home[i]}/.ssh/id_rsa > /dev/null 2>&1
	if [ $? -gt 0 ]; then
		su ${real_user[i]} -c "ssh-keygen -N '' -t rsa -f ${real_home[i]}/.ssh/id_rsa" > /dev/null 2>&1
	fi
	((i++))
done

exit 0
