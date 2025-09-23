#!/bin/bash
set -e

WESTON_CMD="weston --backend=vnc-backend.so \
    --socket=wayland-remote \
    --width=520 --height=800 \
    --disable-transport-layer-security \
    --idle-time=0 \
    --shell=desktop"

APP_CMD="/usr/share/speedifyui/speedify_ui"

while true; do
    echo "Starting Weston..."

    $WESTON_CMD 2>&1 | while IFS= read -r line; do
        echo "$line"

        if [[ "$line" =~ .*New\ VNC\ client\ connected ]]; then
            echo "VNC client detected, launching app..."
            WAYLAND_DISPLAY=wayland-remote $APP_CMD &
        fi

        if [[ "$line" =~ .*VNC\ Client\ disconnected ]]; then
            echo "VNC client disconnected, killing speedify_ui_* processes..."
            pkill -f 'speedify_ui'
        fi
    done

    echo "Weston crashed or exited, restarting in 5s..."
    sleep 5
done
