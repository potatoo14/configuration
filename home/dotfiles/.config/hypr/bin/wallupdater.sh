#!/usr/bin/env bash

solarpaper=~/.config/hypr/bin/solarpaper
walldir=/home/potato/Archive/wallpapers/_favorites

setwall() {
	hyprctl dispatch exec "swaybg -m fill -i \"$1\""
	# shellcheck disable=SC2016
	hyprctl dispatch exec 'sleep 3; kill $(pgrep swaybg | head -n -1)'
}

if [[ -n "$1" ]]; then
	setwall "$1"
else
	wallfile="$($solarpaper -lsd $walldir)"
	[[ -e $wallfile ]] || wallfile="$($solarpaper -flsd $walldir)"
	setwall "$wallfile"
fi
