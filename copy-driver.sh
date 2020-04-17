#!/bin/sh
set -e

MT76="$1"
CROS="$2"

[ -n "$MT76" -a -n "$CROS" ] || {
	echo "Usage: $0 <path_to_mt76> <path_to_chromium_os>"
	exit 1
}

if [ -f "$MT76/drivers/net/wireless/mediatek/mt76/tx.c" ]; then
	MT76="$MT76/drivers/net/wireless/mediatek/mt76"
elif [ \! -f "$MT76/tx.c" ]; then
	echo "mt76 driver not found in '$MT76'"
	exit 1
fi

CONFIG="chromeos/config/x86_64/chromeos-intel-pineview.flavour.config"
if [ -f "$CROS/src/third_party/kernel/v4.14/$CONFIG" ]; then
	CROS="$CROS/src/third_party/kernel/v4.14"
elif [ \! -f "$CROS/$CONFIG" ]; then
	echo "Chromium OS v4.14 kernel not found in '$CROS'"
	exit 1
fi

if grep -q MT7615E "$CROS/$CONFIG"; then
	echo "Build patch already applied"
else
	patch -d "$CROS" -p1 < ./v4.14/mt76.patch
fi

rm -rf "$CROS/drivers/net/wireless/mt76"
cp -av ./v4.14/files/* "$CROS/"
cp -av `ls "$MT76"/*.[ch] | grep -v mt76x02` "$CROS/drivers/net/wireless/mt76/"
cp -av "$MT76"/mt7615/*.[ch] "$CROS/drivers/net/wireless/mt76/mt7615/"
touch "$CROS/drivers/net/wireless/mt76/airtime.c"
touch "$CROS/drivers/net/wireless/mt76/pci.c"
touch "$CROS/drivers/net/wireless/mt76/mt7615/pci_init.c"
touch "$CROS/drivers/net/wireless/mt76/mt7615/pci_mac.c"
