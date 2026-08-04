#!/usr/bin/env bash

wallpath=~/.config/hypr/wallpath

hyprexec() {
	hyprctl eval 'hl.exec_cmd([[ '"$1"' ]])'
}

setwall() {
	hyprexec "swaybg -m fill -i \"$1\""
	# shellcheck disable=SC2016
	hyprexec 'sleep 3; kill $(pgrep swaybg | head -n -1)'
	echo "$1" > "$wallpath"
}

if [[ "$1" == "restore" ]]; then
  setwall "$(cat "$wallpath")"
else
	setwall "$1"
fi
