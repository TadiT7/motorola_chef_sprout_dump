#!/system/bin/sh
#
# Copyright (c) 2013-2015, Motorola LLC  All rights reserved.
#

SCRIPT=${0#/system/bin/}

[ "$1" == "-f" ] && FORCE=1

MID=`cat /sys/block/mmcblk0/device/manfid`
MID=${MID#0x0000}
echo ${MID}
if [ "$MID" != "13" ] ; then
  echo "emmc_ffu_13.sh Result: FAIL"
  echo "$SCRIPT: manufacturer not supported" > /dev/kmsg
  exit
fi
echo "Manufacturer: Micron"

# Skip anything other than this model of
# Mircron is S0J97Y
PNM=`cat /sys/block/mmcblk0/device/name`
FIRMWARE_VERSION=`cat /sys/block/mmcblk0/device/fwrev`
FIRMWARE_VERSION=${FIRMWARE_VERSION#0x3}
FIRMWARE_VERSION=${FIRMWARE_VERSION:0-4:4}
FIRMWARE_VERSION_HEX=(0x$FIRMWARE_VERSION)
FIRMWARE_VERSION_DEC=$((FIRMWARE_VERSION_HEX))


echo "Device Name: $PNM"
echo "Firmware Version: $FIRMWARE_VERSION"
echo "Firmware Version DEC:$FIRMWARE_VERSION_DEC"


#0x3341514d30305244
#0x3644454d30305353 test FW
#0x3333484d30305357 offical FW
#5357 = 21335
#544e = 21582


case "$PNM" in
  "S0J97Y")
   if [ "$FIRMWARE_VERSION_DEC" -ge "21582" ] ; then
      echo "Result: PASS"
      echo "$SCRIPT: firmware already updated" > /dev/kmsg
      exit
    fi
    ;;
    *)

esac
# Flash the firmware
echo "Starting upgrade..."
if [ "$PNM" = "S0J97Y" ] ; then
  /system/bin/sync
  /system/bin/emmc_ffu -yR

  STATUS=$?

  if [ "$STATUS" != "0" ] ; then
    echo "Result: FAIL"
    echo "$SCRIPT: firmware update failed ($STATUS)" > /dev/kmsg
    exit
  fi

  echo "Result: PASS"
  echo "$SCRIPT: firmware updated successfully" > /dev/kmsg
  /system/bin/sync

fi

