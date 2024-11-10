#!/usr/bin/env bash

set -ev

BLUE_PORT="$INPUT_BLUE_PORT"
GREEN_PORT="$INPUT_GREEN_PORT"
NAME="$INPUT_NAME"
STRIP_COMPONENTS="$INPUT_STRIP_COMPONENTS"

BASE_DIR="/apps/$NAME"
NGINX_CONFIG="/etc/nginx/sites-available/$NAME"
CURRENT_PORT="$(grep -oP 'proxy_pass http://localhost:\K\d+' "$NGINX_CONFIG")"

if [ "$CURRENT_PORT" == "$BLUE_PORT" ]; then
  CURRENT='blue'
  TARGET='green'
  TARGET_PORT="$GREEN_PORT"
else
  CURRENT='green'
  TARGET='blue'
  TARGET_PORT="$BLUE_PORT"
fi

CURRENT_CONFIG="$BASE_DIR/$CURRENT/ecosystem.config.js"
TARGET_DIR="$BASE_DIR/$TARGET"
TARGET_CONFIG="$TARGET_DIR/ecosystem.config.js"

rm -rf "${TARGET_DIR:?}/"* "${TARGET_DIR:?}/".*
tar --overwrite "--strip-components=$STRIP_COMPONENTS" -xzf "$NAME.tgz" -C "$TARGET_DIR"
sed -i -e "s/\$TARGET_PORT/$TARGET_PORT/" -e "s/\$TARGET/$TARGET/" "$TARGET_CONFIG"

pm2 start "$TARGET_CONFIG" --env production
pm2 stop --silent "$CURRENT_CONFIG" || :
pm2 delete --silent "$CURRENT_CONFIG" || :
pm2 save

sudo sed -i -e "s/proxy_pass http:\/\/localhost:[0-9]*;/proxy_pass http:\/\/localhost:$TARGET_PORT;/" "$NGINX_CONFIG"
sudo systemctl restart nginx
