################################################################################
#
# module-rtl8192cu-fixes
#
################################################################################

MODULE_RTL8192CU_FIXES_VERSION = fe5a5b4070b975fc0a216cbea44a4f707eb6d153
MODULE_RTL8192CU_FIXES_SITE = https://github.com/pvaret/rtl8192cu-fixes.git
MODULE_RTL8192CU_FIXES_SITE_METHOD = git


define MODULE_RTL8192CU_FIXES_BUILD_MODULE_CMDS
	$(TARGET_MAKE_ENV) \
	CC="$(TARGET_CC)" \
	USER_EXTRA_CFLAGS="-Wno-error=date-time" \
	ARCH=$(ARCH) \
	CROSS_COMPILE=$(TARGET_CROSS_PREFIX) \
	KSRC="$($(PKG)_KSRC)" \
		$(MAKE) -C $($(PKG)_BUILDDIR)
endef

define MODULE_RTL8192CU_FIXES_INSTALL_MODULE_CMDS
	$(INSTALL) -m 0755 -d $(MODULE_RTL8192CU_FIXES_TARGET_DIR)
	$(MODULE_RTL8192CU_FIXES_FAKEROOT) $(INSTALL) -m 0755 -d $(MODULE_RTL8192CU_FIXES_TARGET_DIR)/lib/modules/$($(PKG)_KERNEL_VERSION)/kernel/drivers/net/wireless
	$(MODULE_RTL8192CU_FIXES_FAKEROOT) cp $($(PKG)_BUILDDIR)/8192cu.ko $(MODULE_RTL8192CU_FIXES_TARGET_DIR)/lib/modules/$($(PKG)_KERNEL_VERSION)/kernel/drivers/net/wireless
endef

#~ define MODULE_RTL8192CU_FIXES_TARGET_CMDS
#~ 	$(MODULE_RTL8192CU_FIXES_FAKEROOT) $(INSTALL) -m 0755 -D package/module-rtl8188eu/blacklist-native-rtl8192.conf $(MODULE_RTL8192CU_FIXES_TARGET_DIR)/etc/modprobe.d/blacklist-native-rtl8192.conf
#~ endef

$(eval $(linux-module-package))
