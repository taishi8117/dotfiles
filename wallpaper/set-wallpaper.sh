#!/bin/bash

gsettings set org.gnome.desktop.background picture-options 'zoom'
# gsettings set org.gnome.desktop.background picture-uri 'file:///home/taishi/Pictures/wallpaper/wallhaven-471vzo_1920x1080.png'

wallpaper_dir="/home/taishi/Pictures/wallpaper"
wallpaper="file://${wallpaper_dir}/$(ls ${wallpaper_dir} | sort -R | tail -1 )"
echo "Setting wallpaper to ${wallpaper}"
gsettings set org.gnome.desktop.background picture-uri "${wallpaper}"
