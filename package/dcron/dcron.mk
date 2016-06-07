################################################################################
#
# dcron
#
################################################################################

DCRON_VERSION = 4.5
DCRON_SITE = http://www.jimpryor.net/linux/releases
# The source code does not specify the version of the GPL that is used.
DCRON_LICENSE = GPL

# Overwrite cron-related Busybox commands if available
ifeq ($(BR2_PACKAGE_BUSYBOX),y)
DCRON_DEPENDENCIES = busybox
endif

define DCRON_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS)
endef

define DCRON_INSTALL_TARGET_CMDS
	$(DCRON_FAKEROOT) $(INSTALL) -D -m0700 $(@D)/crond $(DCRON_TARGET_DIR)/usr/sbin/crond
	$(DCRON_FAKEROOT) $(INSTALL) -D -m4755 $(@D)/crontab $(DCRON_TARGET_DIR)/usr/bin/crontab
	$(DCRON_FAKEROOT) $(INSTALL) -D -m0644 $(@D)/extra/root.crontab $(DCRON_TARGET_DIR)/etc/cron.d/system
	
	# Busybox provides run-parts, so there is no need to use nor install provided run-cron
	$(DCRON_FAKEROOT) $(SED) 's#/usr/sbin/run-cron#/bin/run-parts#g' $(DCRON_TARGET_DIR)/etc/cron.d/system
	
	$(DCRON_FAKEROOT) mkdir -p -m=700 $(DCRON_TARGET_DIR)/var/spool/cron
	$(DCRON_FAKEROOT) mkdir -p -m=700 $(DCRON_TARGET_DIR)/var/spool/cron/crontabs
	
	$(DCRON_FAKEROOT) $(INSTALL) -d \
	        $(DCRON_TARGET_DIR)/etc/cron.daily \
	        $(DCRON_TARGET_DIR)/etc/cron.hourly \
	        $(DCRON_TARGET_DIR)/etc/cron.monthly \
	        $(DCRON_TARGET_DIR)/etc/cron.weekly

endef

define DCRON_INSTALL_INIT_SYSV
	$(DCRON_FAKEROOT) $(INSTALL) -D -m 0755 package/dcron/crond.init \
		$(DCRON_TARGET_DIR)/etc/init.d/crond
		
	$(DCRON_FAKEROOT) $(INSTALL) -D -m 0644 package/dcron/crond.default \
		$(DCRON_TARGET_DIR)/etc/default/crond
		
	$(DCRON_FAKEROOT) $(INSTALL) -d -m 0755 $(DCRON_TARGET_DIR)/etc/rc.d/rc.startup.d
	$(DCRON_FAKEROOT) $(INSTALL) -d -m 0755 $(DCRON_TARGET_DIR)/etc/rc.d/rc.shutdown.d
	
	$(DCRON_FAKEROOT) ln -fs ../../init.d/crond \
		$(DCRON_TARGET_DIR)/etc/rc.d/rc.startup.d/S50crond
	
	$(DCRON_FAKEROOT) ln -fs ../../init.d/crond \
		$(DCRON_TARGET_DIR)/etc/rc.d/rc.shutdown.d/S50crond
endef

$(eval $(generic-package))
