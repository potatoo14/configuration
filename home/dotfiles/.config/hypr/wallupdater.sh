#!/usr/bin/env bash

TIME1="$HOME/Archive/wallpapers/_favorites/anime morning.jpg"
TIME2="$HOME/Archive/wallpapers/_favorites/zzz high up.jpeg"
TIME3="$HOME/Archive/wallpapers/_favorites/anime girl with cats.png"
TIME4="$HOME/Archive/wallpapers/_favorites/crane.png"
TIME5="$HOME/Archive/wallpapers/_favorites/20240606_003444_nord.jpg"
TIME6="$HOME/Archive/wallpapers/_favorites/rain_yofukashinouta.png"
TIME7="$HOME/Archive/wallpapers/_favorites/late night.jpg"
TIME8="$HOME/Archive/wallpapers/_favorites/brain.png"

HOUR=$(date +%-H) # 24H format (0-23)

if ((HOUR >= 7 && HOUR < 8)); then
	TARGET_WP="$TIME1"
elif ((HOUR >= 8 && HOUR < 14)); then
	TARGET_WP="$TIME2"
elif ((HOUR >= 14 && HOUR < 18)); then
	TARGET_WP="$TIME3"
elif ((HOUR >= 18 && HOUR < 19)); then
	TARGET_WP="$TIME4"
elif ((HOUR >= 19 && HOUR < 23)); then
	TARGET_WP="$TIME5"
elif ((HOUR >= 23 && HOUR < 1)); then
	TARGET_WP="$TIME6"
elif ((HOUR >= 1 && HOUR < 3)); then
	TARGET_WP="$TIME7"
else
	TARGET_WP="$TIME8"
fi

~/.config/hypr/setwall.sh "$TARGET_WP"
