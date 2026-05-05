#!/bin/bash

PORT=$1

if [ -z "$PORT" ]; then
    echo "Usage: ./delete_api.sh <port>"
    exit 1
fi

sudo systemctl stop api$PORT
sudo systemctl disable api$PORT
sudo rm /etc/systemd/system/api$PORT.service
sudo rm /etc/nginx/sites-enabled/api$PORT
sudo rm /etc/nginx/sites-available/api$PORT
rm -rf /home/ubuntu/api$PORT
sudo systemctl daemon-reload
sudo systemctl reload nginx

echo "API on port $PORT deleted"
