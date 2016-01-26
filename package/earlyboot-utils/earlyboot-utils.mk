################################################################################
#
# earlyboot-utils
#
################################################################################

EARLYBOOT_UTILS_VERSION = d63101264767b7fbf3f28c57310cbe08d816c4c2

ifeq ($(COLIBRI_LOCAL_DEVELOPMENT),y)
EARLYBOOT_UTILS_SITE = $(call github,Colibri-Embedded,earlyboot-utils,$(EARLYBOOT_UTILS_VERSION))
else
EARLYBOOT_UTILS_SITE=$(BR2_EXTERNAL)/../earlyboot-utils
EARLYBOOT_UTILS_SITE_METHOD = local
endif

EARLYBOOT_UTILS_LICENSE = GPLv2
EARLYBOOT_UTILS_LICENSE_FILES = LICENSE

define EARLYBOOT_UTILS_BUILD_CMDS
	$(MAKE1) -C $(@D) CC="$(TARGET_CC)" DESTDIR=$(EARLYBOOT_UTILS_TARGET_DIR)
endef 

define EARLYBOOT_UTILS_INSTALL_TARGET_CMDS
	$(EARLYBOOT_UTILS_FAKEROOT) -- $(MAKE1) -C $(@D) DESTDIR=$(EARLYBOOT_UTILS_TARGET_DIR) install
endef

$(eval $(generic-package))
