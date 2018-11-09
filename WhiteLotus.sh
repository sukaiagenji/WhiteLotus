#!/bin/sh
# Installer for White Lotus Alexa Front End
#
# See LICENSE file for copyright and license details

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
		do_abort
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
		do_alexaconfig
	fi
}

do_alexaconfig () {
	whiptail --yesno "Have you downloaded your AVS credentials JSON file (config.json)?" --defaultno 15 60 2
	RET=$?
	if [ $RET -eq 0 ]; then
		ALEXA_CONFIG_JSON=$(whiptail --inputbox "Please enter the absolute path to your config.json file." 15 60 "/home/pi/config.json" 3>&1 1>&2 2>&3)
	elif [ $RET -eq 1 ]; then
		whiptail --msgbox "\
Please input your AVS credentials. You will need both your \
Client ID and Client ID name from the 'Other devices and \
platforms' tab under your AVS product's Securty Profile. \
" 15 60 1
		do_avsclientid
	fi
	if [ ! -f $ALEXA_CONFIG_JSON ]; then
		whiptail --msgbox "AVS credentials configuration file not found!" 15 60 1
		do_alexaconfig
	else
		do_avsinstall
	fi

}

do_avsclientid() {
	ALEXA_CLIENT_ID=$(whiptail --inputbox "Please enter your AVS Client ID." 15 60 "" 3>&1 1>&2 2>&3)
	EXITSTATUS=$?
	if [ $EXITSTATUS = 0 ]; then
		if [ -z "$ALEXA_CLIENT_ID" ]; then
			whiptail --msgbox "AVS Client ID cannot be empty." 15 60 1
			do_avsclientid
		fi
		do_avsproductid
	else
		do_abort
	fi
}

do_avsproductid() {
	ALEXA_PRODUCT_ID=$(whiptail --inputbox "Please enter your AVS Client ID name." 15 60 "" 3>&1 1>&2 2>&3)
	EXITSTATUS=$?
	if [ $EXITSTATUS = 0 ]; then
		if [ -z "$ALEXA_PRODUCT_ID" ]; then
			whiptail --msgbox "AVS Client ID name cannot be empty." 15 60 1
			do_avsproductid
		fi
		do_avsconfigwrite
		do_avsproductserial
	else
		do_abort
	fi
}

do_avsconfigwrite() {
	touch config.json
	cat <<EOF > config.json
{
 "deviceInfo": {
  "clientId": "$ALEXA_CLIENT_ID",
  "productId": "$ALEXA_PRODUCT_ID"
 }
}
EOF
	ALEXA_CONFIG_JSON=$(pwd)
	ALEXA_CONFIG_JSON+="/config.json"
}

do_avsproductserial() {
	ALEXA_SERIAL_NUMBER=$(whiptail --inputbox "Please enter a serial number for your product. Any string of characters will work." 15 60 "123456" 3>&1 1>&2 2>&3)
	EXITSTATUS=$?
	if [ $EXITSTATUS = 0 ]; then
		if [ -z "$ALEXA_SERIAL_NUMBER" ]; then
			whiptail --msgbox "AVS Client Serial Number cannot be empty." 15 60 1
			do_avsproductserial
		fi
	else
		do_abort
	fi
}


do_avsinstall() {
	echo "Downloading necessary installation files..."
	wget https://raw.githubusercontent.com/alexa/avs-device-sdk/master/tools/Install/setup.sh
	wget https://raw.githubusercontent.com/alexa/avs-device-sdk/master/tools/Install/genConfig.sh
	wget https://raw.githubusercontent.com/alexa/avs-device-sdk/master/tools/Install/pi.sh
	echo
	echo "Changing the setup.sh script to allow JSON data to display..."
	sed -i '/      -DCMAKE_BUILD_TYPE=DEBUG \\/a \ \ \ \ \ \ -DACSDK_EMIT_SENSITIVE_LOGS=ON \\' setup.sh
	echo
	whiptail --msgbox "\
Running the Alexa AVS Sample App build. This will take \
a while. It is suggested to stay close, as you'll need \
to accept licensing during installtion.\
" 15 60 1
	sudo bash setup.sh $ALEXA_CONFIG_JSON -s $ALEXA_SERIAL_NUMBER
	echo
	echo "Changing ownership of all files back to user pi..."
	sudo chown -R pi.pi *
	echo
	echo "Changing the startsample.sh script for minimal stdout..."
	sed -i 's/DEBUG9/CRITICAL/' startsample.sh
}

do_afterinstall() {
	echo "Deleting unneeded AVS files..."
}

do_chromiuminstall() {
	whiptail --msgbox "\
Alexa AVS Sample App has been built. Next, Chromium and \
required dependancies will be installed if necessary.\
" 15 60 1
	sudo apt-get install -y --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox chromium-browser
}

do_checkstartup() {
	#TODO - create the script to install White❀Lotus as a service on startup, including a systemctl package, then check if we're putting it in or not.
}

do_abort() {
	whiptail --msgbox "Installation of White❀Lotus aborted! Press OK to exit." 15 60 1
}

do_start
do_recommend
do_ask_install
do_afterinstall
do_chromiuminstall
do_checkstartup
