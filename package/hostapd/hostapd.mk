################################################################################
#
# hostapd
#
################################################################################

HOSTAPD_VERSION = 2.3
HOSTAPD_SITE = http://hostap.epitest.fi/releases
HOSTAPD_SUBDIR = hostapd
HOSTAPD_CONFIG = $(HOSTAPD_DIR)/$(HOSTAPD_SUBDIR)/.config
HOSTAPD_DEPENDENCIES = host-pkgconf libnl
HOSTAPD_CFLAGS = $(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include/libnl3/
HOSTAPD_LICENSE = GPLv2/BSD-3c
HOSTAPD_LICENSE_FILES = README
HOSTAPD_CONFIG_SET =

HOSTAPD_CONFIG_ENABLE = \
	CONFIG_ACS \
	CONFIG_FULL_DYNAMIC_VLAN \
	CONFIG_HS20 \
	CONFIG_IEEE80211AC \
	CONFIG_IEEE80211N \
	CONFIG_IEEE80211R \
	CONFIG_INTERNAL_LIBTOMMATH \
	CONFIG_INTERWORKING \
	CONFIG_LIBNL32 \
	CONFIG_VLAN_NETLINK

HOSTAPD_CONFIG_DISABLE =

# libnl-3 needs -lm (for rint) and -lpthread if linking statically
# And library order matters hence stick -lnl-3 first since it's appended
# in the hostapd Makefiles as in LIBS+=-lnl-3 ... thus failing
ifeq ($(BR2_STATIC_LIBS),y)
HOSTAPD_LIBS += -lnl-3 -lm -lpthread
endif

ifeq ($(BR2_INET_IPV6),)
	HOSTAPD_CONFIG_DISABLE += CONFIG_IPV6
endif

# Try to use openssl if it's already available
ifeq ($(BR2_PACKAGE_OPENSSL),y)
	HOSTAPD_DEPENDENCIES += openssl
	HOSTAPD_LIBS += $(if $(BR2_STATIC_LIBS),-lcrypto -lz)
	HOSTAPD_CONFIG_EDITS += 's/\#\(CONFIG_TLS=openssl\)/\1/'
else
	HOSTAPD_CONFIG_DISABLE += CONFIG_EAP_PWD
	HOSTAPD_CONFIG_EDITS += 's/\#\(CONFIG_TLS=\).*/\1internal/'
endif

ifeq ($(BR2_PACKAGE_HOSTAPD_EAP),y)
	HOSTAPD_CONFIG_ENABLE += \
		CONFIG_EAP \
		CONFIG_RADIUS_SERVER \

	# Enable both TLS v1.1 (CONFIG_TLSV11) and v1.2 (CONFIG_TLSV12)
	HOSTAPD_CONFIG_ENABLE += CONFIG_TLSV1
else
	HOSTAPD_CONFIG_DISABLE += CONFIG_EAP
	HOSTAPD_CONFIG_ENABLE += \
		CONFIG_NO_ACCOUNTING \
		CONFIG_NO_RADIUS
endif

ifeq ($(BR2_PACKAGE_HOSTAPD_WPS),y)
	HOSTAPD_CONFIG_ENABLE += CONFIG_WPS
endif

define HOSTAPD_CONFIGURE_CMDS
	cp $(@D)/hostapd/defconfig $(HOSTAPD_CONFIG)
	sed -i $(patsubst %,-e 's/^#\(%\)/\1/',$(HOSTAPD_CONFIG_ENABLE)) \
		$(patsubst %,-e 's/^\(%\)/#\1/',$(HOSTAPD_CONFIG_DISABLE)) \
		$(patsubst %,-e '1i%=y',$(HOSTAPD_CONFIG_SET)) \
		$(patsubst %,-e %,$(HOSTAPD_CONFIG_EDITS)) \
		$(HOSTAPD_CONFIG)
endef

define HOSTAPD_BUILD_CMDS
	$(TARGET_MAKE_ENV) CFLAGS="$(HOSTAPD_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" LIBS="$(HOSTAPD_LIBS)" \
		$(MAKE) CC="$(TARGET_CC)" -C $(@D)/$(HOSTAPD_SUBDIR)
endef

define HOSTAPD_INSTALL_IFUPDOWN
	$(HOSTAPD_FAKEROOT) $(INSTALL) -m 0755 -D package/hostapd/ifupdown.sh \
		$(HOSTAPD_TARGET_DIR)/etc/hostapd/ifupdown.sh
		
	$(HOSTAPD_FAKEROOT) $(INSTALL) -d -m 0755 $(HOSTAPD_TARGET_DIR)/etc/network/if-up.d
	$(HOSTAPD_FAKEROOT) $(INSTALL) -d -m 0755 $(HOSTAPD_TARGET_DIR)/etc/network/if-down.d
	$(HOSTAPD_FAKEROOT) $(INSTALL) -d -m 0755 $(HOSTAPD_TARGET_DIR)/etc/network/if-pre-up.d
	$(HOSTAPD_FAKEROOT) $(INSTALL) -d -m 0755 $(HOSTAPD_TARGET_DIR)/etc/network/if-post-down.d
	
	$(HOSTAPD_FAKEROOT) $(INSTALL) -m 0755 -D package/hostapd/ifupdown.sh \
		$(HOSTAPD_TARGET_DIR)/etc/hostapd/ifupdown.sh
		
	$(HOSTAPD_FAKEROOT) ln -fs ../../hostapd/ifupdown.sh \
		$(HOSTAPD_TARGET_DIR)/etc/network/if-up.d/hostapd
		
	$(HOSTAPD_FAKEROOT) ln -fs ../../hostapd/ifupdown.sh \
		$(HOSTAPD_TARGET_DIR)/etc/network/if-down.d/hostapd
		
	$(HOSTAPD_FAKEROOT) ln -fs ../../hostapd/ifupdown.sh \
		$(HOSTAPD_TARGET_DIR)/etc/network/if-pre-up.d/hostapd
		
	$(HOSTAPD_FAKEROOT) ln -fs ../../hostapd/ifupdown.sh \
		$(HOSTAPD_TARGET_DIR)/etc/network/if-post-down.d/hostapd
endef

define HOSTAPD_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/$(HOSTAPD_SUBDIR)/hostapd \
		$(HOSTAPD_TARGET_DIR)/usr/sbin/hostapd
	$(INSTALL) -m 0755 -D $(@D)/$(HOSTAPD_SUBDIR)/hostapd_cli \
		$(HOSTAPD_TARGET_DIR)/usr/bin/hostapd_cli
	$(HOSTAPD_INSTALL_IFUPDOWN)
endef

$(eval $(generic-package))
