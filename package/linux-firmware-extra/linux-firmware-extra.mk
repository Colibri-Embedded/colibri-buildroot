################################################################################
#
# linux-firmware-extra
#
################################################################################

LINUX_FIRMWARE_EXTRA_VERSION = 5a90e6cb335ef7e894579d1ca101dfc2fe327443
LINUX_FIRMWARE_EXTRA_SITE = https://github.com/Colibri-Embedded/linux-firmware-extra.git
LINUX_FIRMWARE_EXTRA_SITE_METHOD = git

# Most firmware files are under a proprietary license, so no need to
# repeat it for every selections above. Those firmwares that have more
# lax licensing terms may still add them on a per-case basis.
LINUX_FIRMWARE_EXTRA_LICENSE += Proprietary

# brcm43430
ifeq ($(BR2_PACKAGE_LINUX_FIRMWARE_BRCM_BCM43430),y)

define LINUX_FIRMWARE_EXTRA_INSTALL_BRCM43430
	$(LINUX_FIRMWARE_EXTRA_FAKEROOT) mkdir -p $(LINUX_FIRMWARE_EXTRA_TARGET_DIR)/lib/firmware/brcm
	
	$(LINUX_FIRMWARE_EXTRA_FAKEROOT) $(INSTALL) -D -m 0664 $(@D)/brcm80211/brcm/brcmfmac43430-sdio.bin \
			$(LINUX_FIRMWARE_EXTRA_TARGET_DIR)/lib/firmware/brcm/brcmfmac43430-sdio.bin
			
	$(LINUX_FIRMWARE_EXTRA_FAKEROOT) $(INSTALL) -D -m 0664 $(@D)/brcm80211/brcm/brcmfmac43430-sdio.txt \
			$(LINUX_FIRMWARE_EXTRA_TARGET_DIR)/lib/firmware/brcm/brcmfmac43430-sdio.txt

	$(LINUX_FIRMWARE_EXTRA_FAKEROOT) $(INSTALL) -D -m 0644 $(@D)/brcm80211/LICENSE \
			$(LINUX_FIRMWARE_EXTRA_TARGET_DIR)/usr/share/license/firmware/LICENSE.broadcom_bcm43430
endef

endif

define LINUX_FIRMWARE_EXTRA_INSTALL_TARGET_CMDS
	$(LINUX_FIRMWARE_EXTRA_FAKEROOT) mkdir -p $(LINUX_FIRMWARE_EXTRA_TARGET_DIR)/lib/firmware
	$(LINUX_FIRMWARE_EXTRA_FAKEROOT) mkdir -p $(LINUX_FIRMWARE_EXTRA_TARGET_DIR)/usr/share/license/firmware
	$(LINUX_FIRMWARE_EXTRA_INSTALL_BRCM43430)
endef


$(eval $(generic-package))
