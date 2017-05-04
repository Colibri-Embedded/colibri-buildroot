################################################################################
#
# module-rpisoftuart
#
################################################################################

MODULE_RPISOFTUART_VERSION = 7c3e91da3f1388c664771834da92daec7bc2782b
MODULE_RPISOFTUART_SITE = https://github.com/Colibri-Embedded/RpiSoft-UART.git
MODULE_RPISOFTUART_SITE_METHOD = git

define MODULE_RPISOFTUART_BUILD_MODULE_CMDS
	$(TARGET_MAKE_ENV) \
	CC="$(TARGET_CC)" \
	USER_EXTRA_CFLAGS="-Wno-error=date-time" \
	ARCH=$(ARCH) \
	CROSS_COMPILE=$(TARGET_CROSS_PREFIX) \
	KSRC="$($(PKG)_KSRC)" \
		$(MAKE) -C $($(PKG)_BUILDDIR)
endef

define MODULE_RPISOFTUART_INSTALL_MODULE_CMDS
	$(INSTALL) -m 0755 -d $(MODULE_RPISOFTUART_TARGET_DIR)
	$(MODULE_RPISOFTUART_FAKEROOT) $(INSTALL) -m 0755 -d           $(MODULE_RPISOFTUART_TARGET_DIR)/lib/modules/$($(PKG)_KERNEL_VERSION)/kernel/drivers/char
	$(MODULE_RPISOFTUART_FAKEROOT) cp $($(PKG)_BUILDDIR)/softuart.ko $(MODULE_RPISOFTUART_TARGET_DIR)/lib/modules/$($(PKG)_KERNEL_VERSION)/kernel/drivers/char
endef

$(eval $(linux-module-package))
