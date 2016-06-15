################################################################################
#
# logrotate
#
################################################################################

LOGROTATE_VERSION = 3.8.7
LOGROTATE_SITE = https://www.fedorahosted.org/releases/l/o/logrotate
LOGROTATE_LICENSE = GPLv2+
LOGROTATE_LICENSE_FILES = COPYING

LOGROTATE_DEPENDENCIES = popt

define LOGROTATE_BUILD_CMDS
	$(MAKE) CC="$(TARGET_CC) $(TARGET_CFLAGS)" LDFLAGS="$(LDFLAGS)" -C $(@D)
endef

define LOGROTATE_INSTALL_TARGET_CMDS
	$(LOGROTATE_FAKEROOT) $(MAKE) PREFIX=$(LOGROTATE_TARGET_DIR) -C $(@D) install
	$(LOGROTATE_FAKEROOT) $(INSTALL) -D -m 0644 package/logrotate/logrotate.conf $(LOGROTATE_TARGET_DIR)/etc/logrotate.conf
	$(LOGROTATE_FAKEROOT) $(INSTALL) -d -m 0755 $(LOGROTATE_TARGET_DIR)/etc/logrotate.d
	$(LOGROTATE_FAKEROOT) $(INSTALL) -d -m 0755 $(LOGROTATE_TARGET_DIR)/etc/cron.daily
	$(LOGROTATE_FAKEROOT) $(INSTALL) -D -m 0755 package/logrotate/logrotate.cron $(LOGROTATE_TARGET_DIR)/etc/cron.daily/logrotate
endef

$(eval $(generic-package))
