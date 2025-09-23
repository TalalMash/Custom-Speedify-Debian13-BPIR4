#!/bin/bash
set -e

TARGET_LABEL="ROUTER"
MOUNT_POINT="/mnt/usb_temp"
DEST_DIR="/etc/systemd/network"
MAX_WAIT=120

echo "$(date): flash_sync_network started" >> /var/log/flash_sync.log

for i in $(seq 1 $MAX_WAIT); do
    DEVICE=$(lsblk -o NAME,LABEL,FSTYPE -nr | awk -v label="$TARGET_LABEL" '$2==label && $3=="vfat" {print "/dev/" $1}')
    if [[ -n "$DEVICE" ]]; then
        echo "$(date): Found device $DEVICE" >> /var/log/flash_sync.log
        break
    fi
    sleep 1
done

if [[ -z "$DEVICE" ]]; then
    echo "$(date): Device not found after $MAX_WAIT seconds. Exiting." >> /var/log/flash_sync.log
    exit 1
fi

mkdir -p "$MOUNT_POINT"

if mount -o ro "$DEVICE" "$MOUNT_POINT"; then
    echo "$(date): Mounted $DEVICE at $MOUNT_POINT" >> /var/log/flash_sync.log
else
    echo "$(date): Failed to mount $DEVICE" >> /var/log/flash_sync.log
    exit 1
fi

rsync -av --delete "$MOUNT_POINT"/ "$DEST_DIR"/ >> /var/log/flash_sync.log 2>&1

umount "$MOUNT_POINT"
echo "$(date): Unmounted $MOUNT_POINT" >> /var/log/flash_sync.log

systemctl restart systemd-networkd
echo "$(date): Restarted systemd-networkd" >> /var/log/flash_sync.log
