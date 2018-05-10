#!/bin/bash
{
unset WSSID
unset WPASS
unset PASSWORD
unset CHARCOUNT

ip link set dev wlan0 up
echo "O-------------------| Change Wifi SSID and Password |----------------------O"
echo "*  Make sure The wifi network is available in this area"
if [ -f /etc/wpa_supplicant/wpa_supplicant.conf ]
then
 	Old_SSID=`grep "ssid=" /etc/wpa_supplicant/wpa_supplicant.conf | awk -F"\"" ' { print $2 } '`
 	DATE=`ls -l /etc/wpa_supplicant/wpa_supplicant.conf | awk ' { print $6 "-" $7 "Time" $8 } '`
 	echo "*  Previous Configuration will be removed"
 	echo ""
 	echo "*  Previous Network - $Old_SSID"
 	echo "*  Last Modified - $DATE"
 	echo ""
else
	echo "*  No Wi-Fi Configuration exist."
	echo "*  Adding .. . . ..."
fi
	echo ""
read -p "New Wi-Fi SSID: " WSSID

echo -n "New Wi-Fi PASS: "
stty -echo
CHARCOUNT=0
while IFS= read -p "$PROMPT" -r -s -n 1 CHAR
do
    if [[ $CHAR == $'\0' ]] ; then
        break
    fi
    if [[ $CHAR == $'\177' ]] ; then
        if [ $CHARCOUNT -gt 0 ] ; then
            CHARCOUNT=$((CHARCOUNT-1))
            PROMPT=$'\b \b'
            PASSWORD="${PASSWORD%?}"
        else
            PROMPT=''
        fi
    else
        CHARCOUNT=$((CHARCOUNT+1))
        PROMPT='*'
        PASSWORD+="$CHAR"
    fi
done
stty echo
WPASS=$PASSWORD
echo -e "\n    Done "
echo -e "\n        New Network    - $WSSID    - \n"
if sudo iwlist wlan0 scan | grep  $WSSID
then
	rm -f	/etc/wpa_supplicant/wpa_supplicant.conf
	wpa_passphrase $WSSID $WPASS > /etc/wpa_supplicant/wpa_supplicant.conf
	echo "   Wifi-Network  $WSSID  Added "
	echo "   Rebooting ... .... "
	sleep 5
	reboot
else
        echo "    Wifi-Network not Found Try Again Later "
        sleep 3
fi
 
echo "O-------------------|           Done             |----------------------O"
} 2>&1 | tee -a  wifi.log
