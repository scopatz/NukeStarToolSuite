#!/bin/bash
#
#~~~ Prop2Nodes ~~~
# A script to update relevant information from a cluster's gateway to its nodes.
# At runtime information about accounts, passwords, groups, and SSH rsa data are updated.
# By Anthony Scopatz, scopatz@gmail.com, http://www.scopatz.com/
# Released under the GNU General Public License version 3.
#
# Dependencies:
# | - OpenSSL with sshfs
# |
# | - NodeKeyGen (nodekeygen.sh): Makes rsa kesy on a node.
# |
# | - NodeList (nodelist.txt): a text file whose lines are three-tuples (whitespace separated).
# | | -----------------------> <node hostname> <node ip address> <username to mount here || "None">
#

#########################
### Color Definitions ###
#########################
C_MSG="\033[0;32m"	#Message Color
C_HNM="\033[1;35m"	#Hostname Color
C_USR="\033[1;36m"	#User Color
C_END="\033[0m"		#Return to Standard colors

###############################
### Read in the nodelist... ###
###############################
let NodeN=0	#The number of nodes
declare -a hostname_list
declare -a ip_list
declare -a userhome_list

#Grab the hostnames
let n=0
for line in `cat nodelist.txt | cut -f1`
do
	hostname_list[$n]="$line";
	((n++))
	((NodeN++))
done

#Grab the IPs
let n=0
for line in `cat nodelist.txt | cut -f2`
do
	ip_list[$n]="$line";
	((n++))
done

#Grab the user whose home is on this host
let n=0
for line in `cat nodelist.txt | cut -f3`
do
	userhome_list[$n]="$line";
	((n++))
done

#Add the users who get mount points to the 'fuse' group
let n=0
while [ $n -lt $NodeN ]
do
	if [ ${userhome_list[n]} != "None" ]; then
		adduser ${userhome_list[n]} fuse > /dev/null 2>&1
	fi
	((n++))
done


################################################
### Copy user and group information to nodes ###
################################################
#Note that this starts from 1, not 0, to ignore the gateway (this) machine.
let n=1		
while [ $n -lt $NodeN ]
do 
	echo -e "${C_MSG}Copying user account information to ${C_HNM}${hostname_list[n]}${C_MSG}...${C_END}"
	scp /etc/passwd* root@${ip_list[n]}:/etc/ 
	scp /etc/shadow* root@${ip_list[n]}:/etc/ 
	scp /etc/group* root@${ip_list[n]}:/etc/ 
	scp /etc/gshadow* root@${ip_list[n]}:/etc/ 
	scp /root/nodekeygen.sh root@${ip_list[n]}:/root/nodekeygen.sh 
	echo
	((n++))
done

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

######################################################################
### Makes home direcotries on Nodes for users that don't have them ###
######################################################################
#Note that this starts from 1, not 0, to ignore the gateway (this) machine.
let n=1
while [ $n -lt $NodeN ]
do 
	let i=0
	while [ $i -lt $RealI ]
	do 
		ssh root@${ip_list[n]} "ls ${real_home[i]} > /dev/null 2>&1"
		if [ $? -gt 0 ]; then
			echo -e "${C_MSG}Making home directory for ${C_USR}${real_user[i]}${C_MSG} on ${C_HNM}${hostname_list[n]}${C_MSG}...${C_END}"
			ssh root@${ip_list[n]} "mkdir ${real_home[i]} > /dev/null 2>&1"
			ssh root@${ip_list[n]} "chown -R ${real_user[i]}:users ${real_home[i]} > /dev/null 2>&1"
		fi
		((i++))
	done
	((n++))
done

#################################################
### Makes SSH Keys for all users on all nodes ###
#################################################

#Great now that is done we need to sync up ssh keys for all users on all machines...
#	1) Make keys on each machine if they don't already exist
#	2) Make a master authorized_keys file for each user on this machine
#	3) Distribute the master file to each node

#Step 1: Generating Keys
echo -e "${C_MSG}Generating SSH keys for all users on all nodes...${C_END}"

#Step 1.1: Make Keys on this machine.
/root/./nodekeygen.sh

#Step 1.2: Make Keys on Nodes.
#Note that this starts from 1, not 0, to ignore the gateway (this) machine.
let n=1
while [ $n -lt $NodeN ]
do
	ssh root@${ip_list[n]} /root/./nodekeygen.sh 
((n++))
done

#Step 2: Merging the id_rsa.pub keys for every user
let i=0
while [ $i -lt $RealI ]
do
	#Get Current keys
	let CurrM=0

	declare -a current_typ
	declare -a current_key
	declare -a current_usr

	let m=0
	while read line 
	do 
		current_typ[$m]=$(echo $line | cut -d\  -f1)
		current_key[$m]=$(echo $line | cut -d\  -f2)
		current_usr[$m]=$(echo $line | cut -d\  -f3)
		((m++))
		((CurrM++))
	done < ${real_home[i]}/.ssh/authorized_keys

	#Get New Keys
	let NewkP=0

	declare -a new_typ
	declare -a new_key
	declare -a new_usr

	let p=0
	line=`cat ${real_home[i]}/.ssh/id_rsa.pub`
	new_typ[$p]=$( echo $line | cut -d\  -f1 )
	new_key[$p]=$( echo $line | cut -d\  -f2 )
	new_usr[$p]=$( echo $line | cut -d\  -f3 )
	((p++))
	((NewkP++))

	#Note that this starts from 1, not 0, to ignore the gateway (this) machine.
	let n=1
	while [ $n -lt $NodeN ]
	do
		line=`ssh root@${ip_list[n]} cat ${real_home[i]}/.ssh/id_rsa.pub`
		new_typ[$p]=$( echo $line | cut -d\  -f1 )
		new_key[$p]=$( echo $line | cut -d\  -f2 )
		new_usr[$p]=$( echo $line | cut -d\  -f3 )
		((p++))
		((NewkP++))
		((n++))
	done

	let p=0
	while [ $p -lt $NewkP ]
	do 
		echo ${new_typ[p]} ${new_key[p]} ${new_usr[p]} >> TempAuth.txt
		((p++))
	done

	let m=0
	while [ $m -lt $CurrM ]
	do
		let CurrNotInNew=1
		let p=0
		while [ $p -lt $NewkP ]
		do 
			if [ "${new_usr[p]}" == "${current_usr[m]}" ]
			then 
				let CurrNotInNew=0
			fi
			((p++))
		done

		if [ 0 -lt $CurrNotInNew ]
		then
			echo ${current_typ[m]} ${current_key[m]} ${current_usr[m]} >> TempAuth.txt
		fi
		((m++))
	done
	
	cp TempAuth.txt ${real_home[i]}/.ssh/authorized_keys
	chown ${real_user[i]}:users ${real_home[i]}/.ssh/authorized_keys
	su ${real_user[i]} -c "chmod 600 ${real_home[i]}/.ssh/authorized_keys"

	unset current_typ
	unset current_key
	unset current_usr
	unset new_typ
	unset new_key
	unset new_usr

	rm TempAuth.txt

	((i++))
done

#Step 3: Copy Master file to all nodes.
let i=0
while [ $i -lt $RealI ]
do
	#Note that this starts from 1, not 0, to ignore the gateway (this) machine.
	let n=1
	while [ $n -lt $NodeN ]
	do
		scp ${real_home[i]}/.ssh/authorized_keys root@${ip_list[n]}:${real_home[i]}/.ssh/authorized_keys
		ssh root@${ip_list[n]} "chown ${real_user[i]}:users ${real_home[i]}/.ssh/authorized_keys"
		((n++))
	done
	((i++))
done

echo -e "${C_MSG}...Intra-cluster transparency achieved!${C_END}"
echo

###############################################################
### Make /etc/hosts file for each node, including this one! ###
###############################################################
echo -e "${C_MSG}Making /etc/hosts files for each node...${C_END}"
rm hosts.tmp > /dev/null 2&>1

let n=0
while [ $n -lt $NodeN ]
do
	if [ "${userhome_list[n]}" == "root" ]; then
		#Add existing parts of /etc/hosts that we don't want to write over
        	while read line
	        do
        	        current_ip=$(echo $line | cut -d\  -f1)
                	current_hn=$(echo $line | cut -d\  -f2)

			let hnIN=1
			let nn=0
			while [ $nn -lt $NodeN ]
			do
				if [ "${current_hn}" == "${hostname_list[nn]}" ]; then
					let hnIN=0
				fi
				((nn++))
			done
			if [ $hnIN -gt 0 ]; then
				echo "${line}" >> hosts.tmp
			elif [ $current_ip == "127.0.1.1" ]; then
				echo "${line}" >> hosts.tmp
			else
				cat /dev/null #Do nothing
			fi
        	done < /etc/hosts

		#Add nodes to /etc/hosts that are not this node
		let nn=0
		while [ $nn -lt $NodeN ]
		do
			if [ "${n}" != "${nn}" ]; then
				 echo "${ip_list[nn]} ${hostname_list[nn]}" >> hosts.tmp
			fi
			((nn++))
		done
		cp hosts.tmp /etc/hosts
		rm hosts.tmp 
	else
		scp root@${ip_list[n]}:/etc/hosts nodehosts.tmp

		#Add existing parts of node@/etc/hosts that we don't want to write over
        	while read line
	        do
        	        current_ip=$(echo $line | cut -d\  -f1)
                	current_hn=$(echo $line | cut -d\  -f2)

			let hnIN=1
			let nn=0
			while [ $nn -lt $NodeN ]
			do
				if [ "${current_hn}" == "${hostname_list[nn]}" ]; then
					let hnIN=0
				fi
				((nn++))
			done
			if [ $hnIN -gt 0 ]; then
				echo "${line}" >> hosts.tmp
			elif [ $current_ip == "127.0.1.1" ]; then
				echo "${line}" >> hosts.tmp
			else
				cat /dev/null #Do nothing
			fi
        	done < nodehosts.tmp

		#Add nodes to /etc/hosts that are not this node
		let nn=0
		while [ $nn -lt $NodeN ]
		do
			if [ "${n}" != "${nn}" ]; then
				 echo "${ip_list[nn]} ${hostname_list[nn]}" >> hosts.tmp
			fi
			((nn++))
		done
		scp hosts.tmp root@${ip_list[n]}:/etc/hosts
		rm hosts.tmp nodehosts.tmp
	fi
	((n++))
done
echo

##################################################
### Make & Distribute  ~/.ssh/known_hosts File ###
##################################################
echo -e "${C_MSG}Updating ~/.ssh/known_hosts for each user...${C_END}"

#Step 1: Generate new  ~/.ssh/known_hosts for each user on the master node.
let i=0
while [ $i -lt $RealI ]
do
	#Touches existing known_hosts file or creates a new one if it doesn't exist
	su ${real_user[i]} -c "touch ${real_home[i]}/.ssh/known_hosts"

	#Add to file by host name
	#Note that this starts from 0, not 1, to include the gateway (this) machine.
	let n=0
	while [ $n -lt $NodeN ]
	do
		oldline=$(su ${real_user[i]} -c "ssh-keygen -H -F ${hostname_list[n]}")
		newline=$( (su ${real_user[i]} -c "ssh-keyscan -H -t rsa ${hostname_list[n]}") 2> /dev/null )

		oldkey=$(echo $oldline | cut -d\  -f11)
		newkey=$(echo $newline | cut -d\  -f3)

		if [ "${oldkey}" !=  "${newkey}" ]; then
			if [ "${oldkey}" != "" ]; then
				su ${real_user[i]} -c "sed -i -e \'/${oldkey}/d\' ${real_home[i]}/.ssh/known_hosts"
			fi
			su ${real_user[i]} -c "echo \"${newline}\" >> ${real_home[i]}/.ssh/known_hosts"
		fi		
		((n++))
	done

	#Add to file by host ip address
	#Note that this starts from 0, not 1, to include the gateway (this) machine.
	let n=0
	while [ $n -lt $NodeN ]
	do
		oldline=$(su ${real_user[i]} -c "ssh-keygen -H -F ${ip_list[n]}")
		newline=$( (su ${real_user[i]} -c "ssh-keyscan -H -t rsa ${ip_list[n]}") 2> /dev/null )

		oldkey=$(echo $oldline | cut -d\  -f11)
		newkey=$(echo $newline | cut -d\  -f3)

		if [ "${oldkey}" !=  "${newkey}" ]; then
			if [ "${oldkey}" != "" ]; then
				su ${real_user[i]} -c "sed -i -e \'/${oldkey}/d\' ${real_home[i]}/.ssh/known_hosts"
			fi
			su ${real_user[i]} -c "echo \"${newline}\" >> ${real_home[i]}/.ssh/known_hosts"
		fi		
		((n++))
	done
	((i++))
done

#Step 2: Copy ~/.ssh/known_hosts for each user from the gateway to the other nodes.
let i=0
while [ $i -lt $RealI ]
do
	#Note that this starts from 1, not 0, to ignore the gateway (this) machine.
	let n=1
	while [ $n -lt $NodeN ]
	do
		su ${real_user[i]} -c "scp ${real_home[i]}/.ssh/known_hosts ${real_user[i]}@${ip_list[n]}:${real_home[i]}/.ssh/known_hosts"
		((n++))
	done
	((i++))
done

echo

########################################################################
### Copy BASH configuration file from gateway to nodes for all users ###
########################################################################
#Note that this starts from 1, not 0, to ignore the gateway (this) machine.
let n=1
while [ $n -lt $NodeN ]
do 
	echo -e "${C_MSG}Copying BASH configuration files to ${C_HNM}${hostname_list[n]}${C_MSG}...${C_END}"
	let i=0
	while [ $i -lt $RealI ]
	do 
		su ${real_user[i]} -c "scp ${real_home[i]}/.bashrc ${real_user[i]}@${ip_list[n]}:${real_home[i]}/.bashrc"
		ls ${real_home[i]}/.bash_profile > /dev/null 2>&1
		if [ $? -gt 0 ]; then
			su ${real_user[i]} -c "echo \"[[ -f ~/.bashrc ]] && . ~/.bashrc\" > ${real_home[i]}/.bash_profile"
		fi
		su ${real_user[i]} -c "scp ${real_home[i]}/.bash_profile ${real_user[i]}@${ip_list[n]}:${real_home[i]}/.bash_profile"
		((i++))
	done
	((n++))
	echo
done

########################################################################
### Copy /usr/share/hostlist from gateway to all nodes if it exists. ###
########################################################################
#This is used for scheduling

ls /usr/share/hostlist > /dev/null 2>&1
if [ $? -eq 0 ]; then
	echo -e "${C_MSG}Copying /usr/share/hostlist to all nodes...${C_END}"

	#Note that this starts from 1, not 0, to ignore the gateway (this) machine.
	let n=1
	while [ $n -lt $NodeN ]
	do 
		scp /usr/share/hostlist ${ip_list[n]}:/usr/share/hostlist
		((n++))
	done

	echo
fi 

########################################################
### Mount extra space in some users home directories ###
########################################################

echo -e "${C_MSG}Mounting extra storage space for users.${C_END}"

#First make the extra space storage directory (/home/user/stor/) on all nodes, including this one.
let i=0
while [ $i -lt $RealI ]
do
	ls ${real_home[i]}/stor/ > /dev/null 2>&1
	if [ $? -gt 0 ]; then
		su ${real_user[i]} -c "mkdir ${real_home[i]}/stor/" > /dev/null 2>&1
	fi
	((i++))
done

#Note that this starts from 1, not 0, to ignore the gateway (this) machine.
let n=1
while [ $n -lt $NodeN ]
do 
	let i=0
	while [ $i -lt $RealI ]
	do 
		ssh root@${ip_list[n]} "ls ${real_home[i]}/stor/" > /dev/null 2>&1
		if [ $? -gt 0 ]; then
			echo -e "${C_MSG}Making extra storage directory for ${C_USR}${real_user[i]}${C_MSG} on ${C_HNM}${hostname_list[n]}${C_MSG}...${C_END}"
			ssh root@${ip_list[n]} su ${real_user[i]} -c \"mkdir ${real_home[i]}/stor/\" > /dev/null 2>&1
		fi
		((i++))
	done
	((n++))
done

#Now, grab a full list of currently mounted directories
mount > TempMount.txt
let MDirD=0
declare -a rem_dir
declare -a loc_dir

let d=0
while read line 
do 
	rem_dir[$d]="$(echo $line | cut -d\  -f1)"
	loc_dir[$d]="$(echo $line | cut -d\  -f3)"
	((d++))
	((MDirD++))
done < TempMount.txt
rm TempMount.txt

#Check and see if the user directory is already mounted...
#...If not, then mount it.
#Note that this starts from 1, not 0, to ignore the gateway (this) machine.
let n=1
while [ $n -lt $NodeN ]
do
	#Is it already mounted?
	let AlreadyMounted=1
	let d=0
	while [ $d -lt $MDirD ]
	do
		if [ ${loc_dir[d]} == "/home/${userhome_list[n]}/stor" ]; then
			let AlreadyMounted=0
		fi
		((d++))
	done

	if [ 0 -lt $AlreadyMounted ]; then
	if [ "None" != "${userhome_list[n]}" ]; then
		echo -e "${C_MSG}Mounting ${C_USR}${userhome_list[n]}${C_MSG} onto ${C_HNM}${hostname_list[n]}${C_MSG}...${C_END}"
		cd /home/${userhome_list[n]}/
		su ${userhome_list[n]} -c "sshfs ${userhome_list[n]}@${ip_list[n]}:/home/${userhome_list[n]}/stor/ /home/${userhome_list[n]}/stor/ -o follow_symlinks"
		cd /root/
	fi
	fi
	((n++))
done
echo

echo -e "${C_MSG}Propagation to nodes in cluser complete!${C_END}"

exit 0
