#!/usr/bin/env bash
set -e
set -o pipefail

PROFILE_DIR=${PROFILE_DIR:-./profile}

mkdir -p $PROFILE_DIR

# docker build . --tag gphotos-sync

cd auth
PUID=$(id -u) PGID=$(id -g) docker-compose up -d --build

echo "giving VNC time to be ready, please wait..."
sleep 2

echo "Open chrome by using the open-chrome.sh script then close that browser window (inside the container) before continuing"
read -p  "Press any key after you have authenticated in your browser at http://$(hostname):6080"

docker-compose down
