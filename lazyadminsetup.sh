#!/usr/bin/env bash
###############################################################################
###                                                               	        ###
###                   LAZYSERVERADMIN / LAZYADMINSETUP.SH 	         	    ###
###                             by mudy45@github                            ###
###                                                                 	    ###
### One hand production server installation. Gamers friendly. Support multi ###
### tasking (installing while watching movie). Requirement: reclining seat, ###
### wireless keyboard, secondary LCD to browse.                            	###
###                                                                        	###
###-------------------------------------------------------------------------###
###                                                                        	###
### Op System		: Ubuntu 16.04.03 Xenial LTS                            ###
### RDBMS			: MariaDB 10.1                                          ###
### Web Server		: Nginx 1.10, 1.12, 1.13, custom		                ###
### PHP Server		: PHP 7                                                	###
### JS Server		: Node.JS                                              	###
### NoSQL Server	:                                                     	###
### Monitoring		: Munin, Nagios											###
### Security		: CFS, Clamav                                         	###
### CMS				: Wordpress                                           	###
###                                                                        	###
###-------------------------------------------------------------------------###
###                                                                         ###
### License	    : GNU General Public License version 3        	            ###
### Copyright   : Mudy Situmorang (mudy45@gmail.com)                        ###
### Tested OS	: Ubuntu 16.04.3 LTS Xenial                                 ###
### Github      : https://github.com/mudy45/sysadminscripts    	            ###
### Version     : 0.1 alpha --> WARNING: DO NOT USE !!!!                    ###
### File        : /lazyadminsetup.sh		                                ###
### Release		: Not Available                                             ###
### Update      : 20170920                                                  ###
###                                                                         ###
###############################################################################

#if [ $(whoami) != 'root' ]; then
#        echo "Must be root to run $0"
#        exit 1;
#fi
#[[ -n ${1} ]] && echo -e "lazyadminsetup.sh ${1}\n"


###############################################################################
### Main                                                             	    ###
### show usage info                                                    	    ###
###-------------------------------------------------------------------------###
###                                                                  	    ###
if [[ $(whoami) != 'root' ]] && echo -e "Must be root to run ${0}\n"; then Fhelp; exit; fi

case "${1}" in
	"-h"|"--help"	)

###############################################################################
### helper functions                                                   	    ###
### Fhelp, Fwaitfor                                                   	    ###
###-------------------------------------------------------------------------###
###                                                                  	    ###
Fhelp()	{
	cat << EOU
	Setup Ubuntu server right after install, 
	-h | --help     	This message.

	EOU
	exit
}

Fwaitfor()	{
	read -rsp -t5 'Press Ctrl-C to abort script...' key
}

###############################################################################
### Variable                                                           	    ###
### 			                                                    	    ###
###-------------------------------------------------------------------------###
###                                                                  	    ###

swappinessNum = "30"
###----> Create swap 2x RAM
swapSize = "1024k"
###----> Change to your SSH port number preference
customSshport = "22222"

###----> Update server time, change to yourtimezone
timedatectl set-timezone Asia/Jakarta
timedatectl 
Fwaitfor

###----> Update server
apt-get update && apt-get upgrade -y && apt-get dist-upgrade && apt-get autoremove && apt-get clean
Fwaitfor

###----> Create swap
touch /var/swap.img
chmod 600 /var/swap.img
dd if=/dev/zero of=/var/swap.img bs=${swapSize} count=1000
mkswap /var/swap.img
swapon /var/swap.img
echo "/var/swap.img    none    swap    sw    0    0" >> /etc/fstab
sysctl -w vm.swappiness=${swappinessNUM}
sysctl -a | grep vm.swappiness
vmstat
free
Fwaitfor

###-----> ufw
sed -i 's/^#?IPV6=.*/IPV6=yes/' /etc/default/ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ${customSshport}
sudo ufw allow 
sudo ufw status verbose
Fwaitfor

###----> Secure SSH port
sed -i 's/^#?Port .*/Port ${customSshport}/' /etc/ssh/sshd_config
sed -i 's/^#?PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
servicectl restart sshd
Fwaitfor

###----> Install other apps
apt-get install mc

###----> Install MariaDB/MySQLd at version, no need to enter root password
/mysql/lazymariasetup.sh

###----> Install Nginx
#/nginx/lazynginxsetup.sh

###----> Install PHP
#/php/lazyphpsetup.sh

###----> Install PHP
#/nodejs/lazynodejssetup.sh

###----> CSF
#/csf/lazycsfsetup.sh

###----> Munin
#/munin/lazymuninsetup.sh

###----> Nagios
#/nagios/lazynagiossetup.sh

###----> Wordpress
#/wp/lazywpsetup.sh

###----> Lazy Server
#/lazyserver/stats.sh
#/lazyserver/bksy.sh

###----> Restart server
sudo reboot
### sudo 

###EOF
