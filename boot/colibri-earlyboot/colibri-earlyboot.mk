################################################################################
#
# colibri-earlyboot make target use live bundles
#
################################################################################
COLIBRI_EARLYBOOT_VERSION = e8ae59f575119e5417f8c663d9a02ae47579f996

define initramfs-import-package
	$($(1)_FAKEROOT) $(TAR) --overwrite -C $(3) -xf $($(2)_TARGET_ARCHIVE);
endef

COLIBRI_EARLYBOOT_SITE = $(call github,Colibri-Embedded,colibri-earlyboot,$(COLIBRI_EARLYBOOT_VERSION))
#COLIBRI_EARLYBOOT_SITE=$(BR2_EXTERNAL)/../colibri-earlyboot
#COLIBRI_EARLYBOOT_SITE_METHOD = local

COLIBRI_EARLYBOOT_LICENSE = GPLv3
COLIBRI_EARLYBOOT_LICENSE_FILES = LICENCE

#COLIBRI_EARLYBOOT_DEPENDENCIES = busybox-initramfs libc libuuid libblkid libsmartcols libacl libattr zlib liblzo ncurses readline parted fatresize fdisk btrfs-progs

ifeq ($(BR2_TARGET_COLIBRI_EARLYBOOT_SUPPORT_EXT4),y)
COLIBRI_EARLYBOOT_FULL_IMPORT += e2fsprogs
endif

ifeq ($(BR2_TARGET_COLIBRI_EARLYBOOT_SUPPORT_BTRFS),y)
COLIBRI_EARLYBOOT_FULL_IMPORT += acl attr btrfs-progs
define COLIBRI_EARLYBOOT_BTRFS_CMDS
	for file in convert debug-tree image find-root map-logical show-super zero-log; do \
		$(COLIBRI_EARLYBOOT_FAKEROOT) -- rm -f $(COLIBRI_EARLYBOOT_TARGET_DIR)/usr/bin/btrfs-$$file; \
	done
endef
endif

# Packages where only some files are used in initramfs image
COLIBRI_EARLYBOOT_TEMP_IMPORT += util-linux
# Packages which full content is used in the initramfs image
COLIBRI_EARLYBOOT_FULL_IMPORT += busybox-initramfs zlib lzo ncurses readline parted fatresize earlyboot-utils

# Combine all used packages and remove duplicates
COLIBRI_EARLYBOOT_DEPENDENCIES = $(sort $(COLIBRI_EARLYBOOT_TEMP_IMPORT) $(COLIBRI_EARLYBOOT_FULL_IMPORT) ) 

# Temp folder used for partialy used packages
COLIBRI_EARLYBOOT_TEMP_DIR = $(@D)/colibri-earlyboot-temp

define COLIBRI_EARLYBOOT_BUILD_CMDS
	mkdir -p $(COLIBRI_EARLYBOOT_TEMP_DIR)
#	Copy libc from TARGET_DIR
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- mkdir -p $(COLIBRI_EARLYBOOT_TEMP_DIR)/lib
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- cp $(TARGET_DIR)/lib/* $(COLIBRI_EARLYBOOT_TEMP_DIR)/lib
# 	Extract content of other packages
	$(foreach impkg,$(COLIBRI_EARLYBOOT_TEMP_IMPORT),$(call initramfs-import-package,COLIBRI_EARLYBOOT,$(call UPPERCASE,$(impkg)), $(COLIBRI_EARLYBOOT_TEMP_DIR)))
endef

define COLIBRI_EARLYBOOT_INSTALL_TARGET_CMDS
#	Install ealyboot files
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- $(MAKE1) -C $(@D) DESTDIR=$(COLIBRI_EARLYBOOT_TARGET_DIR) install
	$(INSTALL) -D -m 0644 $(@D)/earlyboot.conf $(SDCARD_DIR)/earlyboot/earlyboot.conf
	$(INSTALL) -D -m 0644 $(@D)/product.sh $(SDCARD_DIR)/earlyboot/product.sh
endef

define COLIBRI_EARLYBOOT_POST_INSTALL
#	Copy libc
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- cp -a $(COLIBRI_EARLYBOOT_TEMP_DIR)/lib/* $(COLIBRI_EARLYBOOT_TARGET_DIR)/lib
#	Copy FDISK
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- cp $(COLIBRI_EARLYBOOT_TEMP_DIR)/sbin/fdisk $(COLIBRI_EARLYBOOT_TARGET_DIR)/sbin
#	Copy full packages
	$(foreach impkg,$(COLIBRI_EARLYBOOT_FULL_IMPORT),$(call initramfs-import-package,COLIBRI_EARLYBOOT,$(call UPPERCASE,$(impkg)), $(COLIBRI_EARLYBOOT_TARGET_DIR)))
	$(COLIBRI_EARLYBOOT_BTRFS_CMDS)
#	Remove unused programs	
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- rm -rf $(COLIBRI_EARLYBOOT_TARGET_DIR)/usr/sbin/{parted,partprobe}
#	Remove unused files
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- rm -rf $(COLIBRI_EARLYBOOT_TARGET_DIR)/usr/share
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- rm -rf $(COLIBRI_EARLYBOOT_TARGET_DIR)/usr/include
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- rm -rf $(COLIBRI_EARLYBOOT_TARGET_DIR)/usr/lib/pkgconfig
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- rm -rf $(COLIBRI_EARLYBOOT_TARGET_DIR)/lib/*.{a,la}
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- rm -rf $(COLIBRI_EARLYBOOT_TARGET_DIR)/usr/lib/*.{a,la}
endef

COLIBRI_EARLYBOOT_POST_INSTALL_TARGET_HOOKS += COLIBRI_EARLYBOOT_POST_INSTALL

define COLIBRI_EARLYBOOT_CREATE_INITRAMFS_IMG
	echo "#!/bin/bash" > $(@D)/create_initramfs.sh
	echo "cd $(COLIBRI_EARLYBOOT_TARGET_DIR)" >> $(@D)/create_initramfs.sh
	echo "find . -print | cpio -o -H newc 2>/dev/null | $(XZ) -f --extreme --check=crc32  > $(SDCARD_DIR)/initramfs.img" >> $(@D)/create_initramfs.sh
	chmod +x $(@D)/create_initramfs.sh
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- $(@D)/create_initramfs.sh
	rm $(@D)/create_initramfs.sh
endef

COLIBRI_EARLYBOOT_POST_INSTALL_TARGET_HOOKS += COLIBRI_EARLYBOOT_CREATE_INITRAMFS_IMG

define COLIBRI_EARLYBOOT_POST_INSTALL_CLENUP
#	Remove temporary directory
	rm -rf $(COLIBRI_EARLYBOOT_TEMP_DIR)
endef

COLIBRI_EARLYBOOT_POST_INSTALL_TARGET_HOOKS += COLIBRI_EARLYBOOT_POST_INSTALL_CLENUP

$(eval $(generic-package))
