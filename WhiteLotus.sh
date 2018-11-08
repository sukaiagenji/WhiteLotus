#!/bin/sh
# Installer for White Lotus Alexa Front End
#
# See LICENSE file for copyright and license details

INTERACTIVE=true
ASK_TO_REBOOT=0

do_about() {
whiptail --msgbox "\
This tool provides a straight-forward way of both \
installing and running the Alexa AVS for Raspberry Pi. \
Originally created by Sukaia Genji using Whiptail, part \
of the Newt library.\
" 15 60 1
}

do_start() {
whiptail --msgbox "\
Welcome to the White❀Lotus installer for Alexa AVS. \
This installer will add the Alexa AVS Sample App to your \
Raspberry Pi. A Raspberry Pi 3 is highly recommended, \
although a Raspberry Pi 2 Model B+ is supported. \
" 15 60 1
}

do_recommend() {
whiptail --msgbox "\
Because of the amount of processing necessary to run \
the Alexa AVS Sample App, it is recommended that you \
have no other applications running on this Raspberry \
Pi.\
" 15 60 1
}

do_ask_install() {
	whiptail --yesno "Are you ready to begin installing White❀Lotus?" --defaultno 15 60 2
	RET=$?
	if [ $RET -eq 0 ]; then
		do_envcheck
	elif [ $RET -eq 1 ]; then
		whiptail --msgbox "Installation of White❀Lotus aborted! Press OK to exit." 15 60 1
	fi
}

do_envcheck() {
	OSVERSION=$(grep "stretch" /etc/os-release)
	if [ -z "$OSVERSION" ]; then
		whiptail --msgbox "\
Your operating system version is currently not supported. \
Please upgrade to Raspbian Stretch to continue.\
" 15 60 1
	else
		echo "Beginning system update. Please wait..."
		echo
		do_update
		do_alexaconfig
		echo
		echo "Downloading and installing the Alexa AVS..."
		
	fi
}

do_update() {
	echo "Checking for system updates..."
	sudo apt-get update
	sudo apt-get upgrade
	#sudo apt-get dist-upgrade
}

do_alexaconfig () {
	whiptail --yesno "Have you downloaded your AVS credentials JSON file (config.json)?" --defaultno 15 60 2
	RET=$?
	if [ $RET -eq 0 ]; then
		ALEXA_CONFIG_JSON=$(whiptail --input "Please enter the absolute path to your config.json file." 15 60 "/home/pi/config.json" 3>&1 1>&2 2>&3)
	elif [ $RET -eq 1 ]; then
		whiptail --msgbox "\
Please input your AVS credentials. You will need both your \
Client ID and Client ID name from the 'Other devices and \
platforms' tab under your AVS product's Securty Profile. \
" 15 60 1
		do_avsclientid
		do_avsproductid
		touch config.json
		cat <<EOF > config.json
{
 "deviceInfo": {
  "clientId": "$ALEXA_CLIENT_ID",
  "productId": "$ALEXA_PRODUCT_ID"
 }
}
EOF
		ALEXA_CONFIG_JSON=$(pwd) + "/config.json"
	fi
	if [ ! -f $ALEXA_CONFIG_JSON ]; then
		whiptail --msgbox "AVS credentials configuration file not found!" 15 60 1
		do_alexaconfig
	else
		do_avsinstall
	fi
}

do_avsclientid() {
	ALEXA_CLIENT_ID=$(whiptail --input "Please enter your AVS Client ID." 15 60 "" 3>&1 1>&2 2>&3)
	if [ -z "ALEXA_CLIENT_ID" ]; then
		whiptail --msgbox "AVS Client ID cannot be empty." 15 60 1
		do_avsclientid
	fi
}

do_avsproductid() {
	ALEXA_PRODUCT_ID=$(whiptail --input "Please enter your AVS Client ID name." 15 60 "" 3>&1 1>&2 2>&3)
	if [ -z "ALEXA_PRODUCT_ID" ]; then
		whiptail --msgbox "AVS Client ID name cannot be empty." 15 60 1
		do_avsproductid
	fi

do_avsinstall () {
	
}

do_start
do_recommend
do_ask_install
