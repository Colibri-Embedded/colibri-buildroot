################################################################################
#
# dhcpcd
#
################################################################################

DHCPCD_VERSION = 6.6.7
DHCPCD_SOURCE = dhcpcd-$(DHCPCD_VERSION).tar.bz2
DHCPCD_SITE = http://roy.marples.name/downloads/dhcpcd
DHCPCD_DEPENDENCIES = host-pkgconf
DHCPCD_LICENSE = BSD-2c

ifeq ($(BR2_INET_IPV6),)
	DHCPCD_CONFIG_OPTS += --disable-ipv6
endif

ifeq ($(BR2_STATIC_LIBS),y)
	DHCPCD_CONFIG_OPTS += --enable-static
endif

ifeq ($(BR2_USE_MMU),)
	DHCPCD_CONFIG_OPTS += --disable-fork
endif

define DHCPCD_CONFIGURE_CMDS
	(cd $(@D); \
	$(TARGET_CONFIGURE_OPTS) ./configure \
		--os=linux \
		--rundir=/run \
		$(DHCPCD_CONFIG_OPTS) )
endef

define DHCPCD_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) \
		-C $(@D) all
endef

ifneq ($(BR2_TARGET_DHCPCD_CUSTOM_CONF),)
define DHCPCD_INSTALL_CUSTOM_CONF
	$(DHCPCD_FAKEROOT) cp $(BR2_TARGET_DHCPCD_CUSTOM_CONF) $(DHCPCD_TARGET_DIR)/etc/
endef
endif

define DHCPCD_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install DESTDIR=$(DHCPCD_TARGET_DIR)
	$(DHCPCD_INSTALL_CUSTOM_CONF)
endef

# NOTE: Even though this package has a configure script, it is not generated
# using the autotools, so we have to use the generic package infrastructure.

$(eval $(generic-package))
