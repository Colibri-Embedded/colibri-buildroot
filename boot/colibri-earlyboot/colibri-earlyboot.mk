################################################################################
#
# colibri-earlyboot make target use live bundles
#
################################################################################
COLIBRI_EARLYBOOT_VERSION = 004171c1c902ef223d68a8cfb409e4923176eb32

define initramfs-import-package
	$($(1)_FAKEROOT) $(TAR) --overwrite -C $(3) -xf $($(2)_TARGET_ARCHIVE);
endef

COLIBRI_EARLYBOOT_SITE = $(call github,Colibri-Embedded,colibri-earlyboot,$(COLIBRI_EARLYBOOT_VERSION))
#COLIBRI_EARLYBOOT_SITE=$(BR2_EXTERNAL)/../colibri-earlyboot
#COLIBRI_EARLYBOOT_SITE_METHOD = local

COLIBRI_EARLYBOOT_LICENSE = GPLv3
COLIBRI_EARLYBOOT_LICENSE_FILES = LICENCE

#COLIBRI_EARLYBOOT_DEPENDENCIES = busybox-initramfs libc libuuid libblkid libsmartcols libacl libattr zlib liblzo ncurses readline parted fatresize fdisk btrfs-progs
COLIBRI_EARLYBOOT_DEPENDENCIES = util-linux zlib lzo ncurses readline parted fatresize busybox-initramfs

COLIBRI_EARLYBOOT_IMPORT = util-linux zlib lzo ncurses readline parted fatresize

COLIBRI_EARLYBOOT_TEMP_DIR = $(@D)/colibri-earlyboot-temp

ifeq ($(BR2_TARGET_COLIBRI_EARLYBOOT_SUPPORT_EXT4),y)
COLIBRI_EARLYBOOT_DEPENDENCIES += e2fsprogs
endif

ifeq ($(BR2_TARGET_COLIBRI_EARLYBOOT_SUPPORT_BTRFS),y)
COLIBRI_EARLYBOOT_DEPENDENCIES += btrfs-progs
COLIBRI_EARLYBOOT_IMPORT += acl attr
endif

define COLIBRI_EARLYBOOT_BUILD_CMDS
	mkdir -p $(COLIBRI_EARLYBOOT_TEMP_DIR)
#	Extract rootfs content to get libc libraries
	$(COLIBRI_EARLYBOOT_FAKEROOT) $(TAR) --overwrite -C $(COLIBRI_EARLYBOOT_TEMP_DIR) -xf $(BINARIES_DIR)/rootfs.tar
# 	Extract content of other packages
	$(foreach impkg,$(COLIBRI_EARLYBOOT_IMPORT),$(call initramfs-import-package,COLIBRI_EARLYBOOT,$(call UPPERCASE,$(impkg)), $(COLIBRI_EARLYBOOT_TEMP_DIR)))
endef

define COLIBRI_EARLYBOOT_INSTALL_TARGET_CMDS
#	Install ealyboot files
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- $(MAKE1) -C $(@D) DESTDIR=$(COLIBRI_EARLYBOOT_TARGET_DIR) install
	$(INSTALL) -D -m 0644 $(@D)/earlyboot.conf $(SDCARD_DIR)/earlyboot/earlyboot.conf
endef

define COLIBRI_EARLYBOOT_POST_INSTALL
#	Copy libc
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- cp -a $(COLIBRI_EARLYBOOT_TEMP_DIR)/lib/* $(COLIBRI_EARLYBOOT_TARGET_DIR)/lib
#	Copy FDISK
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- cp $(COLIBRI_EARLYBOOT_TEMP_DIR)/sbin/fdisk $(COLIBRI_EARLYBOOT_TARGET_DIR)/sbin
#	Copy whole packages
	$(call initramfs-import-package,COLIBRI_EARLYBOOT,BUSYBOX_INITRAMFS, $(COLIBRI_EARLYBOOT_TARGET_DIR))
	$(call initramfs-import-package,COLIBRI_EARLYBOOT,NCURSES, $(COLIBRI_EARLYBOOT_TARGET_DIR))
	$(call initramfs-import-package,COLIBRI_EARLYBOOT,READLINE, $(COLIBRI_EARLYBOOT_TARGET_DIR))
	$(call initramfs-import-package,COLIBRI_EARLYBOOT,ZLIB, $(COLIBRI_EARLYBOOT_TARGET_DIR))
	$(call initramfs-import-package,COLIBRI_EARLYBOOT,LZO, $(COLIBRI_EARLYBOOT_TARGET_DIR))
	$(call initramfs-import-package,COLIBRI_EARLYBOOT,PARTED, $(COLIBRI_EARLYBOOT_TARGET_DIR))
	$(COLIBRI_EARLYBOOT_FAKEROOT) -- rm -rf $(COLIBRI_EARLYBOOT_TARGET_DIR)/usr/sbin/{parted,partprobe}
	$(call initramfs-import-package,COLIBRI_EARLYBOOT,FATRESIZE, $(COLIBRI_EARLYBOOT_TARGET_DIR))
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
	echo "cd $(COLIBRI_EARLYBOOT_TEMP_DIR)" >> $(@D)/create_initramfs.sh
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
