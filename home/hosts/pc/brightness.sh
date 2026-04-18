#!/bin/sh
ddcutil setvcp x10 "$1" 15
pkill -RTMIN+2 waybar
