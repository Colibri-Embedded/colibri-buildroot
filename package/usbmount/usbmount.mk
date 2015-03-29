################################################################################
#
# usbmount
#
################################################################################

USBMOUNT_VERSION = 0.0.22
USBMOUNT_SOURCE = usbmount_$(USBMOUNT_VERSION).tar.gz
USBMOUNT_SITE = http://snapshot.debian.org/archive/debian/20141023T043132Z/pool/main/u/usbmount
USBMOUNT_DEPENDENCIES = udev lockfile-progs
USBMOUNT_LICENSE = BSD-2c
USBMOUNT_LICENSE_FILES = debian/copyright

define USBMOUNT_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/usbmount $(USBMOUNT_TARGET_DIR)/usr/share/usbmount/usbmount

	$(INSTALL) -m 0755 -D $(@D)/00_create_model_symlink 	\
		$(USBMOUNT_TARGET_DIR)/etc/usbmount/usbmount.d/00_create_model_symlink
	$(INSTALL) -m 0755 -D $(@D)/00_remove_model_symlink 	\
		$(USBMOUNT_TARGET_DIR)/etc/usbmount/usbmount.d/00_remove_model_symlink

	$(INSTALL) -m 0644 -D $(@D)/usbmount.rules $(USBMOUNT_TARGET_DIR)/lib/udev/rules.d/usbmount.rules
	$(INSTALL) -m 0644 -D $(@D)/usbmount.conf $(USBMOUNT_TARGET_DIR)/etc/usbmount/usbmount.conf

	mkdir -p $(addprefix $(USBMOUNT_TARGET_DIR)/media/usb,0 1 2 3 4 5 6 7)
endef

$(eval $(generic-package))
