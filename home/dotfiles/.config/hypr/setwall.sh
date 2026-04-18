#!/bin/sh

# this is not needed anymore because of walldaemon.sh
# echo "\$wall = $1" > ~/.config/hypr/wallpaper.conf

hyprctl dispatch exec "uwsm app -- swaybg -m fill -i \"$1\""

# start a new swaybg instance, wait 3 seconds, and kill all other instances
# shellcheck disable=SC2016
hyprctl dispatch exec 'sleep 3; kill $(pgrep swaybg | head -n -1)'

