#!/bin/bash

gsettings set org.gnome.desktop.interface text-scaling-factor 1.0

xrandr --output eDP-1 --mode 3840x2400 --scale 1.0x1.0 --output DP-3 --mode 1920x1080 --rotate normal --left-of eDP-1 --scale 2.0x2.0
xrandr --output eDP-1 --pos 3840x0
xrandr --output eDP-1 --scale 0.9999x0.9999

/usr/bin/regolith-look refresh
