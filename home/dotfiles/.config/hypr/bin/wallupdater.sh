#!/usr/bin/env bash

args=lsd

solarpaper() {
	~/.config/hypr/bin/solarpaper "$@" ~/Archive/wallpapers/_favorites 
}

hyprexec() {
	hyprctl eval 'hl.exec_cmd([[ '"$1"' ]])'
}

setwall() {
	hyprexec "swaybg -m fill -i \"$1\""
	# shellcheck disable=SC2016
	hyprexec 'sleep 3; kill $(pgrep swaybg | head -n -1)'
}

if [[ -n "$1" ]]; then
	setwall "$1"
else
	wallfile=$(solarpaper -"$args")
	[[ -e "$wallfile" ]] || wallfile="$(solarpaper -f"$args")"
	setwall "$wallfile"
fi
