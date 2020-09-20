#!/bin/sh
set -e

MT76="$1"
CROS_BASE="$2"

[ -n "$MT76" -a -n "$CROS_BASE" ] || {
	echo "Usage: $0 <path_to_mt76> <path_to_chromium_os>"
	exit 1
}

if [ -f "$MT76/drivers/net/wireless/mediatek/mt76/tx.c" ]; then
	MT76="$MT76/drivers/net/wireless/mediatek/mt76"
elif [ \! -f "$MT76/tx.c" ]; then
	echo "mt76 driver not found in '$MT76'"
	exit 1
fi

copy_kernel() {
	local ver="$1"
	case "$ver" in
		4.14) CONFIG="chromeos/config/x86_64/chromeos-intel-pineview.flavour.config";;
		4.19) CONFIG="chromeos/config/arm64/chromiumos-mediatek.flavour.config";;
	esac

	CROS="$CROS_BASE"
	if [ -f "$CROS/src/third_party/kernel/v$ver/$CONFIG" ]; then
		CROS="$CROS/src/third_party/kernel/v$ver"
	elif [ \! -f "$CROS/$CONFIG" ]; then
		echo "Chromium OS v$ver kernel not found in '$CROS'"
		exit 1
	fi
	if grep -qE '(MT7615E|MT7663S)' "$CROS/$CONFIG"; then
		echo "Build patch already applied"
	else
		patch -d "$CROS" -p1 < ./v$ver/mt76.patch
	fi

	rm -rf "$CROS/drivers/net/wireless/mt76"
	cp -avL ./v$ver/files/* "$CROS/"
	cp -avL `ls "$MT76"/*.[ch] | grep -v mt76x02` "$CROS/drivers/net/wireless/mt76/"
	cp -avL "$MT76"/mt7615/*.[ch] "$CROS/drivers/net/wireless/mt76/mt7615/"
	touch "$CROS/drivers/net/wireless/mt76/airtime.c"
	touch "$CROS/drivers/net/wireless/mt76/pci.c"
	touch "$CROS/drivers/net/wireless/mt76/mt7615/pci_init.c"
	touch "$CROS/drivers/net/wireless/mt76/mt7615/pci_mac.c"
}

case "$CROS_BASE" in
	*/v4.14) copy_kernel 4.14;;
	*/v4.19) copy_kernel 4.19;;
	*)
		copy_kernel 4.14
		copy_kernel 4.19
	;;
esac


