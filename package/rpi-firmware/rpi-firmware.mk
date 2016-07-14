################################################################################
#
# rpi-firmware
#
################################################################################

# https://github.com/raspberrypi/firmware/archive/1.20160209.tar.gz

#~ RPI_FIRMWARE_VERSION = 565197e2f830388155dfd6ba713ea32a75697a26
RPI_FIRMWARE_VERSION = 6364331ee24c03108b4a572cb218164480b9275b
RPI_FIRMWARE_SITE = $(call github,raspberrypi,firmware,$(RPI_FIRMWARE_VERSION))
RPI_FIRMWARE_LICENSE = BSD-3c
RPI_FIRMWARE_LICENSE_FILES = boot/LICENCE.broadcom
RPI_FIRMWARE_INSTALL_TARGET = NO
RPI_FIRMWARE_INSTALL_IMAGES = YES
RPI_FIRMWARE_INSTALL_SDCARD = YES

ifeq ($(BR2_PACKAGE_RPI_FIRMWARE_INSTALL_DTBS),y)
#~ RPI_FIRMWARE_DEPENDENCIES += host-rpi-firmware
define RPI_FIRMWARE_INSTALL_DTB
	$(INSTALL) -D -m 0644 $(@D)/boot/bcm2708-rpi-b.dtb $(BINARIES_DIR)/rpi-firmware/bcm2708-rpi-b.dtb
	$(INSTALL) -D -m 0644 $(@D)/boot/bcm2708-rpi-b-plus.dtb $(BINARIES_DIR)/rpi-firmware/bcm2708-rpi-b-plus.dtb
	$(INSTALL) -D -m 0644 $(@D)/boot/bcm2709-rpi-2-b.dtb $(BINARIES_DIR)/rpi-firmware/bcm2709-rpi-2-b.dtb
	$(INSTALL) -D -m 0644 $(@D)/boot/bcm2710-rpi-3-b.dtb $(BINARIES_DIR)/rpi-firmware/bcm2710-rpi-3-b.dtb
	for ovldtb in  $(@D)/boot/overlays/*.dtbo; do \
		$(INSTALL) -D -m 0644 $${ovldtb} $(BINARIES_DIR)/rpi-firmware/overlays/$${ovldtb##*/} || exit 1; \
	done
endef
define RPI_FIRMWARE_INSTALL_DTB_SDCARD
	$(INSTALL) -D -m 0644 $(@D)/boot/bcm2708-rpi-b.dtb $(SDCARD_DIR)/bcm2708-rpi-b.dtb
	$(INSTALL) -D -m 0644 $(@D)/boot/bcm2708-rpi-b-plus.dtb $(SDCARD_DIR)/bcm2708-rpi-b-plus.dtb
	$(INSTALL) -D -m 0644 $(@D)/boot/bcm2709-rpi-2-b.dtb $(SDCARD_DIR)/bcm2709-rpi-2-b.dtb
	$(INSTALL) -D -m 0644 $(@D)/boot/bcm2710-rpi-3-b.dtb $(SDCARD_DIR)/bcm2710-rpi-3-b.dtb
	for ovldtb in  $(@D)/boot/overlays/*.dtbo; do \
		$(INSTALL) -D -m 0644 $${ovldtb} $(SDCARD_DIR)/overlays/$${ovldtb##*/} || exit 1; \
	done
endef
endif

ifeq ($(BR2_PACKAGE_RPI_FIRMWARE_CUSTOM_CONFIG),y)
RPI_FIRMWARE_CONFIG_TXT		= $(BR2_PACKAGE_RPI_FIRMWARE_CONFIG_TXT)
RPI_FIRMWARE_CMDLINE_TXT	= $(BR2_PACKAGE_RPI_FIRMWARE_CMDLINE_TXT)
else
RPI_FIRMWARE_CONFIG_TXT		= package/rpi-firmware/config.txt
RPI_FIRMWARE_CMDLINE_TXT	= package/rpi-firmware/cmdline.txt
endif

define RPI_FIRMWARE_INSTALL_IMAGES_CMDS
	$(INSTALL) -D -m 0644 $(@D)/boot/bootcode.bin $(BINARIES_DIR)/rpi-firmware/bootcode.bin
	$(INSTALL) -D -m 0644 $(@D)/boot/start$(BR2_PACKAGE_RPI_FIRMWARE_BOOT).elf $(BINARIES_DIR)/rpi-firmware/start.elf
	$(INSTALL) -D -m 0644 $(@D)/boot/fixup$(BR2_PACKAGE_RPI_FIRMWARE_BOOT).dat $(BINARIES_DIR)/rpi-firmware/fixup.dat
	$(INSTALL) -D -m 0644 $(RPI_FIRMWARE_CONFIG_TXT) $(BINARIES_DIR)/rpi-firmware/config.txt
	$(INSTALL) -D -m 0644 $(RPI_FIRMWARE_CMDLINE_TXT) $(BINARIES_DIR)/rpi-firmware/cmdline.txt
	$(RPI_FIRMWARE_INSTALL_DTB)
endef

define RPI_FIRMWARE_INSTALL_SDCARD_CMDS
	$(INSTALL) -D -m 0644 $(@D)/boot/bootcode.bin $(SDCARD_DIR)/bootcode.bin
	$(INSTALL) -D -m 0644 $(@D)/boot/start$(BR2_PACKAGE_RPI_FIRMWARE_BOOT).elf $(SDCARD_DIR)/start.elf
	$(INSTALL) -D -m 0644 $(@D)/boot/fixup$(BR2_PACKAGE_RPI_FIRMWARE_BOOT).dat $(SDCARD_DIR)/fixup.dat
	$(INSTALL) -D -m 0644 $(RPI_FIRMWARE_CONFIG_TXT) $(SDCARD_DIR)/config.txt
	$(INSTALL) -D -m 0644 $(RPI_FIRMWARE_CMDLINE_TXT) $(SDCARD_DIR)/cmdline.txt
	$(RPI_FIRMWARE_INSTALL_DTB_SDCARD)
endef

#~ # We have no host sources to get, since we already
#~ # bundle the script we want to install.
#~ HOST_RPI_FIRMWARE_SOURCE =
#~ HOST_RPI_FIRMWARE_DEPENDENCIES =

#~ define HOST_RPI_FIRMWARE_INSTALL_CMDS
#~ 	$(INSTALL) -D -m 0755 package/rpi-firmware/mkknlimg $(HOST_DIR)/usr/bin/mkknlimg
#~ endef

$(eval $(generic-package))
#~ $(eval $(host-generic-package))
