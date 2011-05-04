#!/bin/bash
#
# CodeIgniter installer script
# Copyright (c) 2011 Adriel Kloppenburg
#
# This script is used to automatilcy install all the compentents needed
# to run the CodeIgniter framework.
#
# This file is part of the codeigniter_base project.
#
# codeigniter_base is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# codeigniter_base is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with codeigniter_base.  If not, please see <http://www.gnu.org/licenses/>.

OPT=$1
VERBOSE=0

# Local ip address
LOCAL_IP=$(ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

# CodeIgniter download URL
CI_URL="http://codeigniter.com/download.php"

CI_DOWNLOAD_NAME="CodeIgniter.zip"
CI_SUB_DIR_NAME="codeigniter"
# Directory to install CodeIgniter too
CI_INSTALL="/var/www/ci"

# Web direcotry
WEB_DIR="/var/www"

# Web host user
WWW_USER="www-data"


# Temp directory
TMP_DIR="/tmp"

# test -e and -E command line args matching
case $OPT in
  -v|--verbose) 
	case "$2" in
		1 )
		VERBOSE=1
			;;
		2 )
		VERBOSE=2
			;;
		* )
		echo "Invalid verbose level. Valid options are [1|2] or check -h for more information."
		exit 1
		;;
	esac
	echo "Verbose mode active" 
    # make sure filename is passed else an error displayed   
  	# [ -z $FILE ] && { echo "File name missing"; exit 1; } || vi $FILE	
  	;;
  -d|-D|--date) 
  	echo "Today is $(date)" 
  	;;
   -[Hh]|--help) 
    echo "Usage: $0 -vd"
    echo "	-v        : Displays detailed information of each step. 1=[--] 2=[-----]"
    echo "	--verbose : Same as -v"
    echo "	-d        : Display current date and time."
	exit 1
    ;;
esac


if [[ -a ~/.ci_installed.tmp ]]; then
	echo "Script has already been executed on this server."
	echo -n "Do you want to continue anyway [y/N]? "
	read INSTALL_ANYWAY
	# echo "boo"
	case $INSTALL_ANYWAY in
		[Yy] )
			echo "Attempting to run script again."
			;;
		[Nn]|'' )
			echo "Exiting script now."
			exit 1		
			;;
		* )
			echo "Unknown response, aborting."
			exit 2
			;;
	esac
else
	touch ~/.ci_installed.tmp	
fi

echo -ne "\nInstalling LightTPD, PHP 5, unzip, SSH (server/client) and htop...\n~23 MB internet usage max\n"
# apt-get -y -q=2 install lighttpd php5-cgi php-apc unzip htop 2> /dev/null
if [[ $VERBOSE == 1 ]]; then
	apt-get -y install lighttpd php5-cgi php-apc unzip htop openssh-client openssh-server
elif [[ $VERBOSE == 2 ]]; then
	apt-get install lighttpd php5-cgi php-apc unzip htop openssh-client openssh-server
else
	apt-get -y -q=2 install lighttpd php5-cgi php-apc unzip htop openssh-client openssh-server
fi

echo "Downloading CodeIgniter..."
if [[ ! -f "${TMP_DIR}/$CI_DOWNLOAD_NAME" ]]; then
	if [[ $VERBOSE == 1 || $VERBOSE == 2 ]]; then
		echo "Downloading CodeIgniter.."
		wget "$CI_URL" --output-document "${TMP_DIR}/$CI_DOWNLOAD_NAME"
	else
		wget -q "$CI_URL" --output-document "${TMP_DIR}/$CI_DOWNLOAD_NAME"
	fi
else
	tput bold
	echo "Notice 01: CodeIgniter already downloaded, will use already downloaded file"	
	tput reset
fi

echo "Setting up CodeIgniter..."
if [[ $VERBOSE == 1 ]]; then
	unzip -q "${TMP_DIR}/$CI_DOWNLOAD_NAME" -d "${TMP_DIR}/${CI_SUB_DIR_NAME}"
elif [[ $VERBOSE == 2 ]]; then
	unzip "${TMP_DIR}/$CI_DOWNLOAD_NAME" -d "${TMP_DIR}/${CI_SUB_DIR_NAME}"
else
	# unzip -qq "download.php" 2> /dev/null
	unzip -qq "${TMP_DIR}/$CI_DOWNLOAD_NAME" -d "${TMP_DIR}/${CI_SUB_DIR_NAME}"
fi

# Move CodeIgniter_2.0.2 into specified codeigniter folder
if [[ -d "${TMP_DIR}/${CI_SUB_DIR_NAME}" ]]; then
	# mv ${TMP_DIR}/${CI_SUB_DIR_NAME}/CodeIgniter*/*  "${TMP_DIR}/${CI_SUB_DIR_NAME}"
	mv ${TMP_DIR}/${CI_SUB_DIR_NAME}/CodeIgniter*/*  "${TMP_DIR}/${CI_SUB_DIR_NAME}/"
else
	tput bold
	echo "Error 01: '${TMP_DIR}/${CI_SUB_DIR_NAME}' directory not found."
	tput reset
	exit 1
fi

# Checks if the CodeIgniter's folder is empty before deleting it
shopt -s nullglob dotglob
files=(${TMP_DIR}/${CI_SUB_DIR_NAME}/CodeIgniter*/*)
(( ${#files[*]} )) || CI_DIR_EMPTY=TRUE
shopt -u nullglob dotglob
if [[ "$CI_DIR_EMPTY" == "TRUE" ]]; then
	rm -r ${TMP_DIR}/${CI_SUB_DIR_NAME}/CodeIgniter*/
fi

if [[ -d "${TMP_DIR}/${CI_SUB_DIR_NAME}" ]]; then

	# Check if /var/www/ci directory already exsits, 
	# if it does then don't try and copy into it again!
	if [[ ! -d "$CI_INSTALL" ]]; then
		mv "${TMP_DIR}/${CI_SUB_DIR_NAME}" "$CI_INSTALL"	
		chown -R $WWW_USER:$WWW_USER "$WEB_DIR"
	else
		tput bold
		echo "Error 02.1: Could not find '${TMP_DIR}/${CI_SUB_DIR_NAME}' directory."
		tput reset
	fi
	
else
	tput bold
	echo "Error 02.2: Could not find '${TMP_DIR}/${CI_SUB_DIR_NAME}' directory."
	tput reset
	exit 1
fi

echo "Enabling PHP in LightTPD"
if [[ -f "/etc/lighttpd/conf-available/10-fastcgi.conf" ]]; then
	mv "/etc/lighttpd/conf-available/10-fastcgi.conf" "/etc/lighttpd/conf-enabled/10-fastcgi.conf"
else
	tput bold
	echo "Error 03.1: no 10-fastcgi module found in LightTPD."
	tput reset
fi
if [[ -f "/etc/lighttpd/conf-available/15-fastcgi-php.conf" ]]; then
	mv "/etc/lighttpd/conf-available/15-fastcgi-php.conf" "/etc/lighttpd/conf-enabled/15-fastcgi-php.conf"
else
	tput bold
	echo "Error 03.2: no 15-fastcgi-php module found in LightTPD."
	tput reset
fi
# Restart LightTPD to apply the new php modules
/etc/init.d/lighttpd restart

# 
# Clean up
# 

# Delete dir /tmp/codeigniter/ (shouldn't be there since it was moved)
# if [[ -d "${TMP_DIR}/${CI_SUB_DIR_NAME}" ]]; then
# 	rm -r "${TMP_DIR}/${CI_SUB_DIR_NAME}"
# else
# 	tput bold
# 	echo "Error 06: '${TMP_DIR}/${CI_SUB_DIR_NAME}' directory not found."
# 	tput reset
# fi

# Delete /tmp/CodeIgniter.zip directory
# if [[ -f "${TMP_DIR}/$CI_DOWNLOAD_NAME" ]]; then
# 	rm -r "${TMP_DIR}/$CI_DOWNLOAD_NAME"
# else
# 	tput bold
# 	echo "Error 07: '${TMP_DIR}/$CI_DOWNLOAD_NAME' directory not found."
# 	tput reset
# fi

echo "Done, you can access CodeIgniter via the fowling URL:"
tput bold
echo "http://$LOCAL_IP/ci/";
tput reset