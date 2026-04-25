#!/usr/bin/env bash

quickshell kill
quickshell -d
pkill -9 hyprpaper
hyprpaper & disown
