#!/usr/bin/env bash

solarpaper() {
    ~/.config/hypr/bin/solarpaper -s -c 3 -d ~/Archive/wallpapers/_favorites "$@"
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
    wallfile=$(solarpaper | shuf -n 1)
    
    if [[ ! -e "$wallfile" ]]; then
        wallfile=$(solarpaper -f | shuf -n 1)
    fi
    
    setwall "$wallfile"
fi
