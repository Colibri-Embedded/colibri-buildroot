################################################################################
#
# dnsmasq
#
################################################################################

DNSMASQ_VERSION = 2.72
DNSMASQ_SOURCE = dnsmasq-$(DNSMASQ_VERSION).tar.xz
DNSMASQ_SITE = http://thekelleys.org.uk/dnsmasq
DNSMASQ_MAKE_ENV = $(TARGET_MAKE_ENV) CC="$(TARGET_CC)"
DNSMASQ_MAKE_OPTS = COPTS="$(DNSMASQ_COPTS)" PREFIX=/usr CFLAGS="$(TARGET_CFLAGS)"
DNSMASQ_MAKE_OPTS += DESTDIR=$(DNSMASQ_TARGET_DIR) LDFLAGS="$(TARGET_LDFLAGS)"
DNSMASQ_DEPENDENCIES = host-pkgconf
DNSMASQ_LICENSE = Dual GPLv2/GPLv3
DNSMASQ_LICENSE_FILES = COPYING COPYING-v3

ifneq ($(BR2_INET_IPV6),y)
	DNSMASQ_COPTS += -DNO_IPV6
endif

ifneq ($(BR2_PACKAGE_DNSMASQ_DHCP),y)
	DNSMASQ_COPTS += -DNO_DHCP
endif

ifeq ($(BR2_PACKAGE_DNSMASQ_DNSSEC),y)
	DNSMASQ_DEPENDENCIES += gmp nettle
	DNSMASQ_COPTS += -DHAVE_DNSSEC
ifeq ($(BR2_STATIC_LIBS),y)
	DNSMASQ_COPTS += -DHAVE_DNSSEC_STATIC
endif
endif

ifneq ($(BR2_PACKAGE_DNSMASQ_TFTP),y)
	DNSMASQ_COPTS += -DNO_TFTP
endif

# NLS requires IDN so only enable it (i18n) when IDN is true
ifeq ($(BR2_PACKAGE_DNSMASQ_IDN),y)
	DNSMASQ_DEPENDENCIES += libidn $(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext) host-gettext
	DNSMASQ_MAKE_OPTS += LIBS+="$(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),-lintl)"
	DNSMASQ_COPTS += -DHAVE_IDN
	DNSMASQ_I18N = $(if $(BR2_ENABLE_LOCALE),-i18n)
endif

ifeq ($(BR2_PACKAGE_DNSMASQ_CONNTRACK),y)
	DNSMASQ_DEPENDENCIES += libnetfilter_conntrack
endif

ifeq ($(BR2_PACKAGE_DNSMASQ_CONNTRACK),y)
define DNSMASQ_ENABLE_CONNTRACK
	$(SED) 's^.*#define HAVE_CONNTRACK.*^#define HAVE_CONNTRACK^' \
		$(DNSMASQ_DIR)/src/config.h
endef
endif

ifeq ($(BR2_PACKAGE_DNSMASQ_LUA),y)
	DNSMASQ_DEPENDENCIES += lua

# liblua uses dlopen when dynamically linked
ifneq ($(BR2_STATIC_LIBS),y)
	DNSMASQ_MAKE_OPTS += LIBS+="-ldl"
endif

define DNSMASQ_ENABLE_LUA
	$(SED) 's/lua5.1/lua/g' $(DNSMASQ_DIR)/Makefile
	$(SED) 's^.*#define HAVE_LUASCRIPT.*^#define HAVE_LUASCRIPT^' \
		$(DNSMASQ_DIR)/src/config.h
endef
endif

ifneq ($(BR2_LARGEFILE),y)
	DNSMASQ_COPTS += -DNO_LARGEFILE
endif

ifeq ($(BR2_PACKAGE_DBUS),y)
	DNSMASQ_DEPENDENCIES += dbus
endif

define DNSMASQ_FIX_PKGCONFIG
	$(SED) 's^PKG_CONFIG = pkg-config^PKG_CONFIG = $(PKG_CONFIG_HOST_BINARY)^' \
		$(DNSMASQ_DIR)/Makefile
endef

ifeq ($(BR2_PACKAGE_DBUS),y)
define DNSMASQ_ENABLE_DBUS
	$(SED) 's^.*#define HAVE_DBUS.*^#define HAVE_DBUS^' \
		$(DNSMASQ_DIR)/src/config.h
endef
else
define DNSMASQ_ENABLE_DBUS
	$(SED) 's^.*#define HAVE_DBUS.*^/* #define HAVE_DBUS */^' \
		$(DNSMASQ_DIR)/src/config.h
endef
endif

define DNSMASQ_BUILD_CMDS
	$(DNSMASQ_FIX_PKGCONFIG)
	$(DNSMASQ_ENABLE_DBUS)
	$(DNSMASQ_ENABLE_LUA)
	$(DNSMASQ_ENABLE_CONNTRACK)
	$(DNSMASQ_MAKE_ENV) $(MAKE1) -C $(@D) $(DNSMASQ_MAKE_OPTS) all$(DNSMASQ_I18N)
endef

ifeq ($(BR2_PACKAGE_DBUS),y)
define DNSMASQ_INSTALL_DBUS
	$(INSTALL) -m 0644 -D $(@D)/dbus/dnsmasq.conf \
		$(DNSMASQ_TARGET_DIR)/etc/dbus-1/system.d/dnsmasq.conf
endef
endif

define DNSMASQ_INSTALL_CONF
	$(DNSMASQ_FAKEROOT) $(INSTALL) -d -m 0755 $(DNSMASQ_TARGET_DIR)/etc/dnsmasq/conf.d
	$(DNSMASQ_FAKEROOT) $(INSTALL) -m 644 -D package/dnsmasq/dnsmasq.conf \
		$(DNSMASQ_TARGET_DIR)/etc/dnsmasq/dnsmasq.conf
endef 

define DNSMASQ_INSTALL_IFUPDOWN
	$(DNSMASQ_FAKEROOT) $(INSTALL) -m 0755 -D package/dnsmasq/ifupdown.sh \
		$(DNSMASQ_TARGET_DIR)/etc/dnsmasq/ifupdown.sh
		
	$(DNSMASQ_FAKEROOT) $(INSTALL) -d -m 0755 $(DNSMASQ_TARGET_DIR)/etc/network/if-up.d
	$(DNSMASQ_FAKEROOT) $(INSTALL) -d -m 0755 $(DNSMASQ_TARGET_DIR)/etc/network/if-down.d
		
	$(DNSMASQ_FAKEROOT) $(INSTALL) -m 0755 -D package/dnsmasq/ifupdown.sh \
		$(DNSMASQ_TARGET_DIR)/etc/dnsmasq/ifupdown.sh
	$(DNSMASQ_FAKEROOT) ln -fs ../../dnsmasq/ifupdown.sh \
		$(DNSMASQ_TARGET_DIR)/etc/network/if-up.d/dnsmasq
	$(DNSMASQ_FAKEROOT) ln -fs ../../dnsmasq/ifupdown.sh \
		$(DNSMASQ_TARGET_DIR)/etc/network/if-down.d/dnsmasq
endef

define DNSMASQ_INSTALL_TARGET_CMDS
	$(DNSMASQ_INSTALL_CONF)
	$(DNSMASQ_INSTALL_IFUPDOWN)
	$(DNSMASQ_MAKE_ENV) $(MAKE) -C $(@D) $(DNSMASQ_MAKE_OPTS) install$(DNSMASQ_I18N)
	mkdir -p $(DNSMASQ_TARGET_DIR)/var/lib/misc/
	$(DNSMASQ_INSTALL_DBUS)
endef

define DNSMASQ_INSTALL_INIT_SYSV
	$(DNSMASQ_FAKEROOT) $(DNSMASQ_FAKEROOT_ENV) $(INSTALL) -D -m 0755 package/dnsmasq/dnsmasq.init \
		$(DNSMASQ_TARGET_DIR)/etc/init.d/dnsmasq
	$(DNSMASQ_FAKEROOT) $(DNSMASQ_FAKEROOT_ENV) $(INSTALL) -D -m 0644 package/dnsmasq/dnsmasq.default \
		$(DNSMASQ_TARGET_DIR)/etc/default/dnsmasq
		
	$(DNSMASQ_FAKEROOT) $(DNSMASQ_FAKEROOT_ENV) $(INSTALL) -d -m 0755 $(DNSMASQ_TARGET_DIR)/etc/rc.d/rc.startup.d
	$(DNSMASQ_FAKEROOT) $(DNSMASQ_FAKEROOT_ENV) $(INSTALL) -d -m 0755 $(DNSMASQ_TARGET_DIR)/etc/rc.d/rc.shutdown.d
	
	$(DNSMASQ_FAKEROOT) $(DNSMASQ_FAKEROOT_ENV) ln -fs ../../init.d/dnsmasq \
		$(DNSMASQ_TARGET_DIR)/etc/rc.d/rc.startup.d/S80dnsmasq
	$(DNSMASQ_FAKEROOT) $(DNSMASQ_FAKEROOT_ENV) ln -fs ../../init.d/dnsmasq \
		$(DNSMASQ_TARGET_DIR)/etc/rc.d/rc.shutdown.d/S80dnsmasq
endef

$(eval $(generic-package))
