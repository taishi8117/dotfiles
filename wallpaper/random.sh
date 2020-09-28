#!/bin/bash

rightpic=$RANDOM
wget -q https://source.unsplash.com/random/1080x1920 -O /tmp/"$rightpic".jpeg

gsettings set org.gnome.desktop.background picture-uri file:////tmp/"$rightpic".jpeg
