#!/bin/bash

gsettings set org.gnome.desktop.interface text-scaling-factor 1.5

xrandr --output DP-3-3 --mode 3840x2160 --scale 1.0x1.0 --output HDMI-1 --mode 1920x1080 --rotate left --left-of DP-3-3 --scale 1.5x1.5
xrandr --output DP-3-3 --pos 1620x0
xrandr --output DP-3-3 --scale 0.9999x0.9999

/usr/bin/regolith-look refresh
