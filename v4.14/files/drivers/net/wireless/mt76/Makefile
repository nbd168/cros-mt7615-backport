export CPTCFG_MAC80211=m
export CPTCFG_MAC80211_LEDS=y
export CPTCFG_MAC80211_DEBUGFS=y
export CPTCFG_MAC80211_RC_MINSTREL=y

subdir-ccflags-y := -I$(src) -include "hdrs/mt76-chrome.h"
subdir-ccflags-y += -I$(src)/hdrs/

subdir-ccflags-y += $(call cc-option,-Wno-error=date-time)
subdir-ccflags-y += $(call cc-option,-Wno-date-time)
# otherwise ieee80211_band vs. nl80211_band warnings come up
subdir-ccflags-y += $(call cc-option,-Wno-enum-compare)
subdir-ccflags-y += $(call cc-option,-Wno-enum-conversion)
subdir-ccflags-y += $(call cc-option,-Wno-int-in-bool-context)
# cfg80211 compatibility porting mechanism sometimes causes these
subdir-ccflags-y += $(call cc-option,-Wno-unused-const-variable)
subdir-ccflags-y += $(call cc-option,-Wno-unused-variable)

obj-$(CONFIG_MT76_CORE) += mac80211/
obj-$(CONFIG_MT76_CORE) += mt76.o
obj-$(CONFIG_MT76_USB) += mt76-usb.o
obj-$(CONFIG_MT76_SDIO) += mt76-sdio.o
obj-$(CONFIG_MT7615_COMMON) += mt7615/

mt76-y := \
	mmio.o util.o trace.o dma.o mac80211.o debugfs.o eeprom.o \
	tx.o agg-rx.o mcu.o airtime.o
mt76-$(CONFIG_PCI) += pci.o
mt76-$(CONFIG_NL80211_TESTMODE) += testmode.o

mt76-usb-y := usb.o usb_trace.o
mt76-sdio-y := sdio.o
