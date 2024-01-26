#!/bin/bash

gsettings set org.gnome.desktop.interface text-scaling-factor 1.7

xrandr --output HDMI-1 --mode 5120x1440 --scale 1.5x1.5

/usr/bin/regolith-look refresh
