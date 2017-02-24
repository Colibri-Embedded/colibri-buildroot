################################################################################
#
# module-rtl8188eu
#
################################################################################

MODULE_RTL8188EU_VERSION = 4.3.0.8_13968
MODULE_RTL8188EU_SOURCE = 8188eu-v$(MODULE_RTL8188EU_VERSION).tar.xz
MODULE_RTL8188EU_SITE = https://dl.dropboxusercontent.com/u/27457926/

#~   # Disable power saving
#~   sed -i 's/^CONFIG_POWER_SAVING \= y/CONFIG_POWER_SAVING = n/' Makefile

define MODULE_RTL8188EU_BUILD_MODULE_CMDS
	$(TARGET_MAKE_ENV) \
	CC="$(TARGET_CC)" \
	USER_EXTRA_CFLAGS="-Wno-error=date-time" \
	ARCH=$(ARCH) \
	CROSS_COMPILE=$(TARGET_CROSS_PREFIX) \
	KSRC="$($(PKG)_KSRC)" \
		$(MAKE) -C $($(PKG)_BUILDDIR)
endef

define MODULE_RTL8188EU_INSTALL_MODULE_CMDS
	$(INSTALL) -m 0755 -d $(MODULE_RTL8188EU_TARGET_DIR)
	$(MODULE_RTL8188EU_FAKEROOT) $(INSTALL) -m 0755 -d           $(MODULE_RTL8188EU_TARGET_DIR)/lib/modules/$($(PKG)_KERNEL_VERSION)/kernel/drivers/net/wireless
	$(MODULE_RTL8188EU_FAKEROOT) cp $($(PKG)_BUILDDIR)/8188eu.ko $(MODULE_RTL8188EU_TARGET_DIR)/lib/modules/$($(PKG)_KERNEL_VERSION)/kernel/drivers/net/wireless
endef

define MODULE_RTL8188EU_INSTALL_TARGET_CMDS
	$(MODULE_RTL8188EU_FAKEROOT) $(INSTALL) -m 0755 -D package/module-rtl8188eu/blacklist-r8188eu.conf $(MODULE_RTL8188EU_TARGET_DIR)/etc/modprobe.d/r8188eu.conf
endef

$(eval $(linux-module-package))
