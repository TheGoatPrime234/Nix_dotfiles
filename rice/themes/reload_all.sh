#!/usr/bin/env bash

pkill -SIGUSR2 waybar 
swaync-client -R
swaync-client -rs
pkill -9 hyprpaper
hyprpaper & disown
hyprctl reload
