# WhiteLotus
A frontend for the Raspberry Pi Alexa AVS that enables card display via Chromium.

## Simple Instructions
Set up Raspbian Stretch (either Lite or Desktop) and run `sudo raspi-config` to your liking.

Go to [Alexa AVS Developer Console](https://developer.amazon.com/avs/home.html), and create or select a product. Once you've done that, select "Security Profile" on the left side, followed by the "Other devices and platforms" on the right near the bottom. Select "Download" to download your `config.json`, which you can now upload to your Raspberry Pi.

Run `git https://github.com/sukaiagenji/WhiteLotus.git` to download White Lotus.

`cd` into where you downloaded White Lotus (usually `~/WhiteLotus`).

Run the installer using `bash installer.sh`. You do not (and really should not) use `sudo` on this command.

Follow all onscreen prompts to install White Lotus!!!

DONE!!!

TODO - Add images of the AVS Developer Console.
