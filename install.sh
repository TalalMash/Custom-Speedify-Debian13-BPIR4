#!/bin/bash
set -e

BASE_DIR="./setup"

echo "Starting deployment..."

deploy_file() {
    local src="$1"
    local dst="$2"
    local perm="$3"

    echo "Installing $dst..."
    cp "$src" "$dst"
    chmod "$perm" "$dst"
    echo "$dst installed with permissions $perm"
}

deploy_file "$BASE_DIR/systemd/weston-vnc.service" "/etc/systemd/system/weston-vnc.service" 644
deploy_file "$BASE_DIR/systemd/router-init.service" "/etc/systemd/system/router-init.service" 644
deploy_file "$BASE_DIR/systemd/flash_sync_network.service" "/etc/systemd/system/flash_sync_network.service" 644

deploy_file "$BASE_DIR/bin/router-init.sh" "/usr/local/bin/router-init.sh" 755
deploy_file "$BASE_DIR/bin/weston-vnc.sh" "/usr/local/bin/weston-vnc.sh" 755
deploy_file "$BASE_DIR/bin/flash_sync_network.sh" "/usr/local/bin/flash_sync_network.sh" 755
deploy_file "$BASE_DIR/config/rt_tables" "/etc/iproute2/rt_tables " 755


echo "Reloading systemd daemon..."
systemctl daemon-reload

for svc in router-init.service weston-vnc.service flash_sync_network.service; do
    echo "Enabling $svc..."
    systemctl enable "$svc"
    echo "Starting $svc..."
    systemctl start "$svc"
done

echo "Done"
