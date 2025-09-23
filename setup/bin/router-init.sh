#!/bin/bash
set -e

echo heartbeat > /sys/devices/platform/gpio-leds/leds/blue:wps/trigger
echo netdev > /sys/devices/platform/gpio-leds/leds/green:status/trigger
echo connectify0 > /sys/devices/platform/gpio-leds/leds/green:status/device_name
echo 1 > /sys/devices/platform/gpio-leds/leds/green:status/link
echo 1 > /sys/devices/platform/gpio-leds/leds/green:status/rx
echo 1 > /sys/devices/platform/gpio-leds/leds/green:status/tx

/usr/share/speedify/DisableRpFilter.sh
modprobe tun
/usr/share/speedify/SpeedifyStartup.sh &

echo 1800000 > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
