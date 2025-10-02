#!/bin/bash
set -euo pipefail

TARGET_LABEL="ROUTER"
MOUNT_POINT="/mnt/usb_temp"
DEST_DIR="/etc/systemd/network"
MAX_WAIT=120

echo "flash_sync_network started"

DEVICE=""
for ((i=0; i<MAX_WAIT; i++)); do
    DEVICE=$(lsblk -o NAME,LABEL,FSTYPE -nr |
        awk -v label="$TARGET_LABEL" '$2==label && $3=="vfat" {print "/dev/" $1; exit}')
    [[ -n "$DEVICE" ]] && break
    sleep 1
done

if [[ -z "$DEVICE" ]]; then
    echo "Device not found after ${MAX_WAIT}s. Exiting."
    exit 1
fi

echo "Found device $DEVICE"

mkdir -p "$MOUNT_POINT"
mount -o ro "$DEVICE" "$MOUNT_POINT"
echo "Mounted $DEVICE at $MOUNT_POINT"

rsync -a --delete "$MOUNT_POINT"/ "$DEST_DIR"/

umount "$MOUNT_POINT"
echo "Unmounted $MOUNT_POINT"

systemctl restart systemd-networkd
echo "Restarted systemd-networkd"
