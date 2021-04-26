#!/usr/bin/env bash

export GODOT=Godot_v3.3-stable_linux_headless.64

apt update && apt upgrade --yes --force-yes
apt install unzip curl git --yes --force-yes

# Godot dependencies
apt install xvfb libxcursor1 libxinerama1 libxrandr2 libxi6 libasound2 libpulse0 libgl1-mesa-glx --yes --force-yes

echo "Get godot"

curl https://downloads.tuxfamily.org/godotengine/3.3/${GODOT}.zip > /tmp/${GODOT}.zip
unzip /tmp/${GODOT}.zip
