################################################################################
#
# ifplugd
#
################################################################################

IFPLUGD_VERSION = 0.28
IFPLUGD_SITE = http://0pointer.de/lennart/projects/ifplugd
IFPLUGD_LICENSE = GPLv2
IFPLUGD_LICENSE_FILES = LICENSE
IFPLUGD_AUTORECONF = YES

# install-strip unconditionally overwrites $(IFPLUGD_TARGET_DIR)/etc/ifplugd/ifplugd.*
IFPLUGD_INSTALL_TARGET_OPTS = DESTDIR=$(IFPLUGD_TARGET_DIR) install-exec
IFPLUGD_CONF_OPTS = --disable-lynx --with-initdir=/etc/init.d/
IFPLUGD_DEPENDENCIES = libdaemon

# Prefer big ifplugd
ifeq ($(BR2_PACKAGE_BUSYBOX),y)
	IFPLUGD_DEPENDENCIES += busybox
endif

define IFPLUGD_INSTALL_FIXUP
	$(INSTALL) -D -m 0644 $(@D)/conf/ifplugd.conf $(IFPLUGD_TARGET_DIR)/etc/ifplugd/ifplugd.conf; \
	$(SED) 's^\(ARGS=.*\)w^\1^' $(IFPLUGD_TARGET_DIR)/etc/ifplugd/ifplugd.conf; \
	$(INSTALL) -D -m 0755 $(@D)/conf/ifplugd.action \
		$(IFPLUGD_TARGET_DIR)/etc/ifplugd/ifplugd.action
endef

IFPLUGD_POST_INSTALL_TARGET_HOOKS += IFPLUGD_INSTALL_FIXUP

define IFPLUGD_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(@D)/conf/ifplugd.init \
		$(IFPLUGD_TARGET_DIR)/etc/init.d/S45ifplugd
	# don't use bash for init script
	$(SED) 's^/bin/bash^/bin/sh^g' $(IFPLUGD_TARGET_DIR)/etc/init.d/S45ifplugd
endef

$(eval $(autotools-package))
