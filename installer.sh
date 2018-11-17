#!/bin/sh
# Installer for White Lotus Alexa Front End
#
# See LICENSE file for copyright and license details

WAKEWORD_ON=false
INSTALL_DIR=$(pwd)

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
		ALEXA_CONFIG_JSON=$(whiptail --inputbox "Please enter the absolute path to your config.json file." 15 60 "$INSTALL_DIR/config.json" 3>&1 1>&2 2>&3)
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
		do_avsproductserial
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
	touch $INSTALL_DIR/config.json
	cat <<EOF > $INSTALL_DIR/config.json
{
 "deviceInfo": {
  "clientId": "$ALEXA_CLIENT_ID",
  "productId": "$ALEXA_PRODUCT_ID"
 }
}
EOF
	ALEXA_CONFIG_JSON="$INSTALL_DIR/config.json"
}

do_avsproductserial() {
	ALEXA_SERIAL_NUMBER=$(whiptail --inputbox "Please enter a serial number for your product. Any string of characters will work." 15 60 "123456" 3>&1 1>&2 2>&3)
	EXITSTATUS=$?
	if [ $EXITSTATUS = 0 ]; then
		if [ -z "$ALEXA_SERIAL_NUMBER" ]; then
			whiptail --msgbox "AVS Client Serial Number cannot be empty." 15 60 1
			do_avsproductserial
		fi
		do_avsinstall
	else
		do_abort
	fi
}


do_avsinstall() {
	echo "Downloading necessary installation files..."
	mkdir AlexaAVS
	pushd AlexaAVS
	sudo rm -f *
	cp $ALEXA_CONFIG_JSON .
	wget https://raw.githubusercontent.com/alexa/avs-device-sdk/master/tools/Install/setup.sh
	wget https://raw.githubusercontent.com/alexa/avs-device-sdk/master/tools/Install/genConfig.sh
	wget https://raw.githubusercontent.com/alexa/avs-device-sdk/master/tools/Install/pi.sh
	echo
	echo "Changing the setup.sh script to allow JSON data to display..."
	sed -i '/      -DCMAKE_BUILD_TYPE=DEBUG \\/a \ \ \ \ \ \ -DACSDK_EMIT_SENSITIVE_LOGS=ON \\' setup.sh
	sed -i 's/pip install flask commentjson/pip3 install flask commentjson/' pi.sh
	whiptail --yesno "Would you like to install a Wake Word sound?" 15 60 2
	RET=$?
	if [ $RET -eq 0 ]; then
		sed -i "/GSTREAMER_AUDIO_SINK=\"autoaudiosink\"/a SOUNDS_DIR=$INSTALL_DIR/sounds" $INSTALL_DIR/AlexaAVS/setup.sh
		sed -i "/  echo \"==============> BUILDING SDK ==============\"/r $INSTALL_DIR/setupsed.txt" $INSTALL_DIR/AlexaAVS/setup.sh
		WAKEWORD_ON=true
	elif [ $RET -eq 1 ]; then
		echo "Skipping Wake Word Support..."
	fi

	whiptail --msgbox "\
Running the Alexa AVS Sample App build. This will take \
a while. It is suggested to stay close, as you'll need \
to accept licensing during installtion.\
" 15 60 1
	sudo bash setup.sh $ALEXA_CONFIG_JSON -s $ALEXA_SERIAL_NUMBER
	popd
	echo
	echo "Changing the startsample.sh script for minimal stdout..."
	sudo sed -i "s/DEBUG9/CRITICAL/" $INSTALL_DIR/AlexaAVS/startsample.sh
	rm -f $INSTALL_DIR/settings.json
	touch $INSTALL_DIR/settings.json
	cat <<EOF > $INSTALL_DIR/settings.json
{
	"WhiteLotusDir": "$INSTALL_DIR",
	"AlexaAVSDir": "$INSTALL_DIR/AlexaAVS"
}
EOF
	echo
	echo "Moving and installing fonts..."
	if [[ ! -d ~/.fonts ]]; then
		mkdir ~/.fonts
	fi
	rm -f ~/.fonts/AmazonEmber*.ttf
	cp $INSTALL_DIR/fonts/* /home/pi/.fonts/
	fc-cache -f /home/pi/.fonts
	do_chromiuminstall
}

do_chromiuminstall() {
	whiptail --msgbox "\
Alexa AVS Sample App has been built. Next, minimal \
required dependancies will be installed if necessary.\
" 15 60 1
	sudo apt-get install -y --no-install-recommends xdotool nodejs npm
	echo "Finding current Raspbian Stretch version, Lite or Desktop..."
	DESKTOPCHECK=$(dpkg --list | grep '^ii' | grep 'raspberrypi-ui-mods')
	if [ ! $? -eq 0 ]; then
		echo "Using Lite mode. Installing necessary apt packages..."
		sudo apt-get install -y --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox chromium-browser gstreamer1.0-alsa gstreamer1.0-libav
	fi
	npm install
	do_checkstartup
}

do_checkstartup() {
	whiptail --msgbox "\
Before we get started running White❀Lotus, if you'd \
prefer, a system service can be installed to start \
everything when your Raspberry Pi is plugged in.
" 15 60 1
	whiptail --yesno "Would you like to install the White❀Lotus service?" 15 60 2
	RET=$?
	if [ $RET -eq 0 ]; then
		do_startupinstall
	elif [ $RET -eq 1 ]; then
		do_finish
	fi
}

do_startupinstall() {
	echo "Finding current Raspbian Stretch version, Lite or Desktop..."
	DESKTOPCHECK=$(dpkg --list | grep '^ii' | grep 'raspberrypi-ui-mods')
	if [ $? -eq 0 ]; then
		echo "Using Desktop mode. Installing necessary scripts..."
		sudo cat <<EOT >> /home/pi/.config/lxsession/LXDE-pi/autostart
@node $INSTALL_DIR/WhiteLotus.js
@xset s off
@xset -dpms
@xset s noblank
@chromium-browser --start-fullscreen --disable-infobars --app=http://localhost:8080/alexa-ctrlprt/
EOT
	xdg-settings set default-web-browser chromium.desktop
	else
		echo "Overwriting openbox script..."
		sudo cp -f $INSTALL_DIR/services/autostart /etc/xdg/openbox/autostart
		sudo sed -i "s:starthere:$INSTALL_DIR:" /etc/xdg/openbox/autostart
		echo "Setting up autologin..."
		sudo systemctl set-default multi-user.target
		CURRENTUSER=$(whoami)
		sudo sed /etc/systemd/system/autologin@.service -i -e "s#^ExecStart=-/sbin/agetty --autologin [^[:space:]]*#ExecStart=-/sbin/agetty --autologin $CURRENTUSER#"
		sudo ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
	fi
	if [[ ! -e ~/.bash_profile ]]; then
		touch ~/.bash_profile
	fi
	cat <<EOT >> ~/.bash_profile
[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && startx -- -nocursor
EOT
	amixer set PCM -- 50%
	do_finishstartup
}

do_finish() {
	whiptail --msgbox "\
White❀Lotus has finished installing!!! From the console,  \
enter the commands\n\
'cd $INSTALL_DIR && node WhiteLotus'\n\
then start Chromium in your preferred method. Enter\n\
'http://localhost:8080/alexa-ctrlprt' into the URL. \
No other configuration is necessary. \
" 15 60 1
	whiptail --yesno "Would you like to reboot now?" 15 60 2
	RET=$?
	if [ $RET -eq 0 ]; then
		sudo reboot
	fi
}

do_finishstartup() {
	whiptail --msgbox "\
White❀Lotus has finished installing!!! After rebooting,  \
White❀Lotus will start, followed by Chrome in console \
mode. No other configuration is necessary. \
" 15 60 1
	whiptail --yesno "Would you like to reboot now?" 15 60 2
	RET=$?
	if [ $RET -eq 0 ]; then
		sudo reboot
	fi
}

do_abort() {
	whiptail --msgbox "Installation of White❀Lotus aborted! Press OK to exit." 15 60 1
}

do_start
do_recommend
do_ask_install
