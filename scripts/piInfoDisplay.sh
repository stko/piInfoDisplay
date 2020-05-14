#!/bin/sh
xset s noblank
xset s off
xset -dpms
openbox --config-file ~/.config/openbox/rc.xml --startup /home/pi/piInfoDisplay/piInfoDisplay.py
