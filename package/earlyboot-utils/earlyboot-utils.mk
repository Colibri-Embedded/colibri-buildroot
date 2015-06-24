################################################################################
#
# earlyboot-utils
#
################################################################################

EARLYBOOT_UTILS_VERSION = c45be9a00f1daa330fd4ec914853ed4eb291e19d

EARLYBOOT_UTILS_SITE = $(call github,Colibri-Embedded,earlyboot-utils,$(EARLYBOOT_UTILS_VERSION))
#EARLYBOOT_UTILS_SITE=$(BR2_EXTERNAL)/../earlyboot-utils
#EARLYBOOT_UTILS_SITE_METHOD = local

EARLYBOOT_UTILS_LICENSE = GPLv2
EARLYBOOT_UTILS_LICENSE_FILES = LICENSE

define EARLYBOOT_UTILS_BUILD_CMDS
	$(MAKE1) -C $(@D) CC="$(TARGET_CC)" DESTDIR=$(EARLYBOOT_UTILS_TARGET_DIR)
endef 

define EARLYBOOT_UTILS_INSTALL_TARGET_CMDS
	$(EARLYBOOT_UTILS_FAKEROOT) -- $(MAKE1) -C $(@D) DESTDIR=$(EARLYBOOT_UTILS_TARGET_DIR) install
endef

$(eval $(generic-package))
