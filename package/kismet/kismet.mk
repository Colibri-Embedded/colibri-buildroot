################################################################################
#
# kismet
#
################################################################################

KISMET_VERSION = Kismet-2014-02-R1
KISMET_SITE = http://www.kismetwireless.net/kismet.git
KISMET_SITE_METHOD = git
KISMET_DEPENDENCIES = host-pkgconf libpcap ncurses libnl
KISMET_CONF_OPTS += --with-netlink-version=3
KISMET_LICENSE = GPLv2+
KISMET_LICENSE_FILES = debian/copyright

# We touch configure.in:
KISMET_AUTORECONF = YES

ifeq ($(BR2_STATIC_LIBS),y)
KISMET_CONF_ENV = LIBS="-lpcap $(shell $(STAGING_DIR)/usr/bin/pcap-config --static --additional-libs)"
endif

ifeq ($(BR2_PACKAGE_PCRE),y)
	KISMET_DEPENDENCIES += pcre
endif

ifeq ($(BR2_PACKAGE_KISMET_CLIENT),y)
	KISMET_TARGET_BINARIES += kismet_client
endif

ifeq ($(BR2_PACKAGE_KISMET_SERVER),y)
	KISMET_TARGET_BINARIES += kismet_server
	KISMET_TARGET_CONFIGS += kismet.conf
endif

ifeq ($(BR2_PACKAGE_KISMET_DRONE),y)
	KISMET_TARGET_BINARIES += kismet_drone
	KISMET_TARGET_CONFIGS += kismet_drone.conf
endif

ifdef KISMET_TARGET_BINARIES
define KISMET_INSTALL_TARGET_BINARIES
	$(INSTALL) -m 755 $(addprefix $(KISMET_DIR)/, $(KISMET_TARGET_BINARIES)) $(KISMET_TARGET_DIR)/usr/bin
endef
endif

ifdef KISMET_TARGET_CONFIGS
define KISMET_INSTALL_TARGET_CONFIGS
	$(INSTALL) -m 644 $(addprefix $(KISMET_DIR)/conf/, $(KISMET_TARGET_CONFIGS)) $(KISMET_TARGET_DIR)/etc
endef
endif

define KISMET_INSTALL_TARGET_CMDS
	$(KISMET_INSTALL_TARGET_BINARIES)
	$(KISMET_INSTALL_TARGET_CONFIGS)
endef

$(eval $(autotools-package))
