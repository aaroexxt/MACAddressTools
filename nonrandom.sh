#!/bin/bash
#SPOOF MAC ADDRESS code for MAC by Aaron Becker
#c0:33:5e:1a:04:79 44:1c:a8:e2:7a:57
read -p "Enter new MAC address: " macAddr
echo "OLD MAC ADDRESS `ifconfig en0 | grep ether`";

echo "searching for services";
services=$(networksetup -listnetworkserviceorder | grep 'Hardware Port')

echo "searching for devices";
while read line; do
    sname=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $2}')
    sdev=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $4}')
    #echo "Current service: $sname, $sdev, $currentservice"
    if [ -n "$sdev" ]; then
        ifout="$(ifconfig $sdev 2>/dev/null)"
        echo "$ifout" | grep 'status: active' > /dev/null 2>&1
        rc="$?"
        if [ "$rc" -eq 0 ]; then
            currentservice="$sname"
            currentdevice="$sdev"
            currentmac=$(echo "$ifout" | awk '/ether/{print $2}')

            # may have multiple active devices, so echo it here
            echo "SERVICE: $currentservice, $currentdevice, $currentmac"
            if [ "$currentservice" = "Wi-Fi" ]; then
            	echo "disabling wifi";
                sudo /System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -z
                echo "modifying MAC addr";
            	sudo ifconfig $currentdevice ether $macAddr || (echo "Failed to set addr" && exit 1);
            fi
        fi
    fi
done <<< "$(echo "$services")"

if [ -z "$currentservice" ]; then
    >&2 echo "Could not find service to modify, is your Wi-Fi on? :("
    #exit 1
else
	echo "fixing wifi";
    sudo networksetup -detectnewhardware
    sleep 1;
    sudo networksetup -setnetworkserviceenabled Wi-Fi off
    sleep 1;
    sudo networksetup -setnetworkserviceenabled Wi-Fi on
fi

echo "NEW MAC ADDRESS `ifconfig en0 | grep ether`";