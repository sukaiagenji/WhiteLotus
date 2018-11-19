#!/bin/sh
# Installer for White Lotus Alexa Front End
#
# See LICENSE file for copyright and license details

set -o errexit  # Exit the script if any statement fails.
set -o nounset  # Exit the script if any uninitialized variable is used.

WAKEWORD_ON=false # Set a variable for Wake Word.
INSTALL_DIR=$(pwd) # Make sure we know what directory we're installing from.

do_about() {
whiptail --msgbox "\
This tool provides a straight-forward way of both \
installing and running the Alexa AVS for Raspberry Pi. \
Originally created by Sukaia Genji using Whiptail, part \
of the Newt library.\
" 15 60 1
}

# See whiptail documentation for these. https://en.wikibooks.org/wiki/Bash_Shell_Scripting/Whiptail

do_start() {
	whiptail --msgbox "\
Welcome to the White❀Lotus installer for Alexa AVS. \
This installer will add the Alexa AVS Sample App to your \
Raspberry Pi. A Raspberry Pi 3 is highly recommended, \
although a Raspberry Pi 2 Model B+ is supported. \
" 15 60 1
	do_recommend
}

do_recommend() {
	whiptail --msgbox "\
Because of the amount of processing necessary to run \
the Alexa AVS Sample App, it is recommended that you \
have no other applications running on this Raspberry \
Pi.\
" 15 60 1
	do_ask_install
}

do_ask_install() {
	if (whiptail --yesno "Are you ready to begin installing White❀Lotus?" --defaultno 15 60 2); then
		do_envcheck
	else
		exit 1
	fi
}

do_envcheck() {
	OSVERSION=$(grep "stretch" /etc/os-release) # Check the Raspberry Pi Raspbian version.
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
	if (whiptail --yesno "Have you downloaded your AVS credentials JSON file (config.json)?" --defaultno 15 60 2); then # Set the config.json file variable.
		ALEXA_CONFIG_JSON=$(whiptail --inputbox "Please enter the absolute path to your config.json file." 15 60 "$INSTALL_DIR/config.json" 3>&1 1>&2 2>&3)
	else
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
	EXITSTATUS=$? # We have to separate the OK/Cancel switch and the input here.
	if [ $EXITSTATUS = 0 ]; then
		if [ -z "$ALEXA_CLIENT_ID" ]; then
			whiptail --msgbox "AVS Client ID cannot be empty." 15 60 1
			do_avsclientid
		fi
		do_avsproductid
	else
		exit 1
	fi
}

do_avsproductid() {
	ALEXA_PRODUCT_ID=$(whiptail --inputbox "Please enter your AVS Client ID name." 15 60 "" 3>&1 1>&2 2>&3)
	EXITSTATUS=$? # We have to separate the OK/Cancel switch and the input here.
	if [ $EXITSTATUS = 0 ]; then
		if [ -z "$ALEXA_PRODUCT_ID" ]; then
			whiptail --msgbox "AVS Client ID name cannot be empty." 15 60 1
			do_avsproductid
		fi
		do_avsconfigwrite
		do_avsproductserial
	else
		exit 1
	fi
}

do_avsconfigwrite() {
	# Since there's not a config.json file already, we have to write one.
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
	EXITSTATUS=$? # We have to separate the OK/Cancel switch and the input here.
	if [ $EXITSTATUS = 0 ]; then
		if [ -z "$ALEXA_SERIAL_NUMBER" ]; then
			whiptail --msgbox "AVS Client Serial Number cannot be empty." 15 60 1
			do_avsproductserial
		fi
		do_avsinstall
	else
		exit 1
	fi
}


do_avsinstall() {
	# We've got all the information we need. Let's start installing.
	echo "Downloading necessary installation files..."
	if [[ ! -d AlexaAVS ]]; then
		mkdir AlexaAVS
	fi
	pushd AlexaAVS # Change to the AlexaAVS directory.
	sudo rm -f *.sh # Delete the setup files from the SDK.
	cp $ALEXA_CONFIG_JSON . # and copy our config.json file into it.
	# Download the primary setup files.
	wget https://raw.githubusercontent.com/alexa/avs-device-sdk/master/tools/Install/setup.sh
	wget https://raw.githubusercontent.com/alexa/avs-device-sdk/master/tools/Install/genConfig.sh
	wget https://raw.githubusercontent.com/alexa/avs-device-sdk/master/tools/Install/pi.sh
	echo
	echo "Changing the setup.sh script to allow JSON data to display..."
	# In order for White Lotus to work, we have to set ACSDK_EMIT_SENSITIVE_LOGS to ON, so let's add a line inside setup.sh.
	sed -i '/      -DCMAKE_BUILD_TYPE=DEBUG \\/a \ \ \ \ \ \ -DACSDK_EMIT_SENSITIVE_LOGS=ON \\' setup.sh
	# And because of a (imo) mistake in the setup script, we have to change pip here to pip3.
	sed -i 's/pip install flask commentjson/pip3 install flask commentjson/' pi.sh
	if (whiptail --yesno "Would you like to install a Wake Word sound?" 15 60 2); then
		# If the user wants to add a Wake Word, we need to add a few things into the setup script.
		sed -i "/GSTREAMER_AUDIO_SINK=\"autoaudiosink\"/a SOUNDS_DIR=$INSTALL_DIR/sounds" $INSTALL_DIR/AlexaAVS/setup.sh
		# The problem is, we can't change the program until it's downloaded, so before building starts, we'll change the proper file.
		# See setupsed.txt to see what will be added.
		sed -i "/  echo \"==============> BUILDING SDK ==============\"/r $INSTALL_DIR/setupsed.txt" $INSTALL_DIR/AlexaAVS/setup.sh
		# Last, we set our variable to true for later.
		WAKEWORD_ON=true
	else
		echo "Skipping Wake Word Support..."
	fi

	whiptail --msgbox "\
Running the Alexa AVS Sample App build. This will take \
a while. It is suggested to stay close, as you'll need \
to accept licensing during installtion.\
" 15 60 1
	# Now, we run the actual install.
	sudo bash setup.sh $ALEXA_CONFIG_JSON -s $ALEXA_SERIAL_NUMBER
	if [[ ! -e $INSTALL_DIR/AlexaAVS/startsample.sh ]]; then
		# Well, something failed while building. Let's just exit.
		echo "Error building the Alexa AVS SampleApp."
		exit 1
	fi
	popd # And change back to the original directory.
	echo
	echo "Changing the startsample.sh script for minimal stdout..."
	# There's no need to view a full list of everything going on. Let's cut that down to almost nothing.
	sudo sed -i "s/DEBUG9/CRITICAL/" $INSTALL_DIR/AlexaAVS/startsample.sh
	# Finally writing the settings.json.
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
	# Well......
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
	# We need to install some dependancies for either version of Raspbian we support.
	sudo apt-get install -y --no-install-recommends xdotool nodejs npm
	echo "Finding current Raspbian Stretch version, Lite or Desktop..."
	if [[ -z $(dpkg -l | grep 'raspberrypi-ui-mods') ]]; then
		echo "Using Lite mode. Installing necessary apt packages..."
		# And if we're using Raspbian Lite, we need a few more packages to make things work.
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
	if (whiptail --yesno "Would you like to install the White❀Lotus service?" 15 60 2); then
		do_startupinstall
	else
		do_finish
	fi
}

do_startupinstall() {
	echo "Finding current Raspbian Stretch version, Lite or Desktop..."
	if [[ ! -z $(dpkg -l | grep 'raspberrypi-ui-mods') ]]; then
		echo "Using Desktop mode. Installing necessary scripts..."
		# Because Desktop mode already runs the X11 server, we just need to add a few lines to start White Lotus and Chromium.
		sudo cat <<EOT >> ~/.config/lxsession/LXDE-pi/autostart
@node $INSTALL_DIR/WhiteLotus.js
@xset s off
@xset -dpms
@xset s noblank
@chromium-browser --start-fullscreen --disable-infobars --app=http://localhost:8080/alexa-ctrlprt/
EOT
	else
		# However, if we're using Lite, we have to add quite a bit.
		echo "Overwriting openbox script..."
		# If you look at the autostart script, you'll see it's not much different from one above after the edit.
		sudo cp -f $INSTALL_DIR/services/autostart /etc/xdg/openbox/autostart
		# But, we need to change the proper directory.
		sudo sed -i "s:starthere:$INSTALL_DIR:" /etc/xdg/openbox/autostart
		echo "Setting up autologin..."
		# This is taken almost verbatum from the raspi-config script.
		sudo systemctl set-default multi-user.target
		CURRENTUSER=$(whoami)
		sudo sed /etc/systemd/system/autologin@.service -i -e "s#^ExecStart=-/sbin/agetty --autologin [^[:space:]]*#ExecStart=-/sbin/agetty --autologin $CURRENTUSER#"
		sudo ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
		# Last for Lite mode, we need to set the .bash_profile to check which display has logged in, and start the X11 server if we need to.
		if [[ ! -e ~/.bash_profile ]]; then
			touch ~/.bash_profile
		fi
		cat <<EOT >> ~/.bash_profile
[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && startx -- -nocursor
EOT
	fi
	# This is personal preference here. Alexa is way too loud if we don't turn the volume down a little.
	amixer set PCM -- 50%
	do_finishstartup
}

do_finish() {
	# No autostart? We'll just give you instructions, then.
	whiptail --msgbox "\
White❀Lotus has finished installing!!! From the console,  \
enter the commands\n\
'cd $INSTALL_DIR && node WhiteLotus'\n\
then start Chromium in your preferred method. Enter\n\
'http://localhost:8080/alexa-ctrlprt' into the URL. \
No other configuration is necessary. \
" 15 60 1
	if (whiptail --yesno "Would you like to reboot now?" 15 60 2); then
		sudo reboot
	fi
}

do_finishstartup() {
	# Autostart? Cool. We're done.
	whiptail --msgbox "\
White❀Lotus has finished installing!!! After rebooting,  \
White❀Lotus will start, followed by Chrome in console \
mode. No other configuration is necessary. \
" 15 60 1
	if (whiptail --yesno "Would you like to reboot now?" 15 60 2); then
		sudo reboot
	fi
}

# Because everything is inside functions, we have to call those functions.
do_start
