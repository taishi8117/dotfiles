#!/bin/bash

gsettings set org.gnome.desktop.interface text-scaling-factor 1.7

xrandr --output DP-3-1-5 --mode 5120x1440 --scale 1.5x1.5

/usr/bin/regolith-look refresh
