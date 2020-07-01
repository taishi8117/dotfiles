#!/bin/bash
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0

xrandr --output HDMI-1 --mode 1920x1080 --rotate normal --scale 1.0x1.0
