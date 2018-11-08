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
	whiptail --yesno "Are you ready to begin installing White❀Lotus?" --defaultno 20 60 2
	RET=$?
	if [ $RET -eq 0 ]; then
		echo "Installing here."
		#do_update();
	elif [ $RET -eq 1 ]; then
		whiptail --msgbox "Installation of White❀Lotus aborted! Press OK to exit." 15 60 1
		return 0
	fi
}

do_start
do_recommend
do_ask_install

