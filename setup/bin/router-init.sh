#!/bin/bash
set -e

echo heartbeat > /sys/devices/platform/gpio-leds/leds/blue:wps/trigger
echo netdev > /sys/devices/platform/gpio-leds/leds/green:status/trigger
echo connectify0 > /sys/devices/platform/gpio-leds/leds/green:status/device_name
echo 1 > /sys/devices/platform/gpio-leds/leds/green:status/link
echo 1 > /sys/devices/platform/gpio-leds/leds/green:status/rx
echo 1 > /sys/devices/platform/gpio-leds/leds/green:status/tx

#Optional, needed for custom module alias
modprobe tun

#Temporary workaround: fork Speedify instead of using the service. 
#TODO: create a custom systemd non blocking target for Speedify service unit
/usr/share/speedify/SpeedifyStartup.sh &
#Needed for captive portal and VLAN (on some buggy hardware)
#/usr/share/speedify/DisableRpFilter.sh

echo 1800000 > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
