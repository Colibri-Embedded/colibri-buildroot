################################################################################
#
# connman
#
################################################################################

CONNMAN_VERSION = 1.34
CONNMAN_SOURCE = connman-$(CONNMAN_VERSION).tar.xz
CONNMAN_SITE = $(BR2_KERNEL_MIRROR)/linux/network/connman
CONNMAN_DEPENDENCIES = libglib2 dbus iptables
CONNMAN_INSTALL_STAGING = YES
CONNMAN_LICENSE = GPLv2
CONNMAN_LICENSE_FILES = COPYING
CONNMAN_CONF_OPTS += \
	$(if $(BR2_PACKAGE_CONNMAN_DEBUG),--enable-debug,--disable-debug)		\
	$(if $(BR2_PACKAGE_CONNMAN_ETHERNET),--enable-ethernet,--disable-ethernet)	\
	$(if $(BR2_PACKAGE_CONNMAN_WIFI),--enable-wifi,--disable-wifi)			\
	$(if $(BR2_PACKAGE_CONNMAN_WISPR),--enable-wispr,--disable-wispr) \
	$(if $(BR2_PACKAGE_CONNMAN_BLUETOOTH),--enable-bluetooth,--disable-bluetooth)	\
	$(if $(BR2_PACKAGE_CONNMAN_LOOPBACK),--enable-loopback,--disable-loopback)	\
	$(if $(BR2_PACKAGE_CONNMAN_NEARD),--enable-neard,--disable-neard) \
	$(if $(BR2_PACKAGE_CONNMAN_OFONO),--enable-ofono,--disable-ofono) \
	$(if $(BR2_INIT_SYSTEMD),--with-systemdunitdir=/usr/lib/systemd/system)

CONNMAN_DEPENDENCIES += \
	$(if $(BR2_PACKAGE_CONNMAN_NEARD),neard) \
	$(if $(BR2_PACKAGE_CONNMAN_OFONO),ofono) \
	$(if $(BR2_PACKAGE_CONNMAN_WISPR),gnutls)

define CONNMAN_INSTALL_INIT_SYSV
	
	$(CONNMAN_FAKEROOT) $(INSTALL) -D -m 0755 package/connman/connman.init \
		$(CONNMAN_TARGET_DIR)/etc/init.d/connman
	$(CONNMAN_FAKEROOT) $(INSTALL) -D -m 0644 package/connman/connman.default \
		$(CONNMAN_TARGET_DIR)/etc/default/connman
		
	$(CONNMAN_FAKEROOT) $(INSTALL) -d -m 0755 $(CONNMAN_TARGET_DIR)/etc/rc.d/rc.sysinit.d	
	$(CONNMAN_FAKEROOT) $(INSTALL) -d -m 0755 $(CONNMAN_TARGET_DIR)/etc/rc.d/rc.shutdown.d
	
	$(CONNMAN_FAKEROOT) ln -fs ../../init.d/connman \
		$(CONNMAN_TARGET_DIR)/etc/rc.d/rc.sysinit.d/S90connman
	$(CONNMAN_FAKEROOT) ln -fs ../../init.d/connman \
		$(CONNMAN_TARGET_DIR)/etc/rc.d/rc.shutdown.d/S60connman
	
endef


ifeq ($(BR2_PACKAGE_CONNMAN_CLIENT),y)
CONNMAN_CONF_OPTS += --enable-client
CONNMAN_DEPENDENCIES += readline

define CONNMAN_INSTALL_CM
	$(CONNMAN_FAKEROOT) $(INSTALL) -m 0755 -D $(@D)/client/connmanctl $(CONNMAN_TARGET_DIR)/usr/bin/connmanctl
endef

CONNMAN_POST_INSTALL_TARGET_HOOKS += CONNMAN_INSTALL_CM
else
CONNMAN_CONF_OPTS += --disable-client
endif

$(eval $(autotools-package))
