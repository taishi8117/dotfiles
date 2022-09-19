#!/bin/bash

gsettings set org.gnome.desktop.interface text-scaling-factor 1.0

xrandr --output eDP-1 --mode 3840x2400 --scale 1.0x1.0
/usr/bin/regolith-look refresh
