#!/bin/bash

gsettings set org.gnome.desktop.interface text-scaling-factor 1.5

xrandr --output DP-2-2 --mode 3840x2160 --scale 1.0x1.0 --output HDMI-1 --mode 1920x1080 --rotate normal --left-of DP-2-2 --scale 1.5x1.5 --output eDP-1 --mode 1920x1080 --rotate normal --scale 1.5x1.5 --left-of DP-2-1 --below HDMI-1
xrandr --output DP-2-2 --pos 2880x0
xrandr --output eDP-1 --pos 0x1620
xrandr --output DP-2-2 --scale 0.9999x0.9999

/usr/bin/regolith-look refresh
