#!/bin/bash

PORT=$1
N=$2

if [ -z "$PORT" ] || [ -z "$N" ]; then
    echo "Usage: ./create_api.sh <port> <n>"
    exit 1
fi

APP_DIR="/home/ubuntu/api$PORT"

mkdir -p $APP_DIR
cp -r /home/ubuntu/api_template/* $APP_DIR/

cd $APP_DIR

VENV_PATH="/home/ubuntu/api_env"

sudo tee /etc/systemd/system/api$PORT.service > /dev/null <<EOF
[Unit]
Description=Flask API $PORT
After=network.target

[Service]
User=ubuntu
WorkingDirectory=$APP_DIR
Environment="PATH=$VENV_PATH/bin"
Environment="PORT=$PORT"
Environment="n=$N"
ExecStart=$VENV_PATH/bin/python app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/nginx/sites-available/api$PORT > /dev/null <<EOF
server {
    listen 80;
    server_name api$PORT.salas.ff.ggbluewhale.store;

    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/api$PORT /etc/nginx/sites-enabled/

sudo systemctl daemon-reload
sudo systemctl enable api$PORT
sudo systemctl start api$PORT

sudo nginx -t && sudo systemctl reload nginx

echo "API deployed at http://api$PORT.salas.ff.ggbluewhale.store → port $PORT with n=$N"
