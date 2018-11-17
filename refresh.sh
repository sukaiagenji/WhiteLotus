WID=$(xdotool search --onlyvisible --class chromium|head -1)
xdotool windowactivate ${WID} key ctrl+r+
