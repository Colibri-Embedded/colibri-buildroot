################################################################################
#
# fake-hwclock
#
################################################################################

FAKE_HWCLOCK_VERSION = 0.10
FAKE_HWCLOCK_SOURCE = fake-hwclock_$(FAKE_HWCLOCK_VERSION).tar.gz
FAKE_HWCLOCK_SITE = http://http.debian.net/debian/pool/main/f/fake-hwclock/
FAKE_HWCLOCK_LICENSE = GPLv2

define FAKE_HWCLOCK_INSTALL_TARGET_CMDS
	# Application
	$(FAKE_HWCLOCK_FAKEROOT) $(INSTALL) -D -m 0755 $(@D)/fake-hwclock $(FAKE_HWCLOCK_TARGET_DIR)/sbin/fake-hwclock
	
	# Init scripts
	$(FAKE_HWCLOCK_FAKEROOT) $(INSTALL) -D -m 0755 package/fake-hwclock/fake-hwclock.init \
		$(FAKE_HWCLOCK_TARGET_DIR)/etc/init.d/fake-hwclock
		
	$(FAKE_HWCLOCK_FAKEROOT) $(INSTALL) -D -m 0644 $(@D)/etc/default/fake-hwclock \
		$(FAKE_HWCLOCK_TARGET_DIR)/etc/default/fake-hwclock
	
	# Store current time as it's closer to reality then 1970 :)
	$(FAKE_HWCLOCK_FAKEROOT) date -u '+%Y-%m-%d %H:%M:%S' > $(FAKE_HWCLOCK_TARGET_DIR)/etc/fake-hwclock.data
	
	# Manual pages
	$(FAKE_HWCLOCK_FAKEROOT) $(INSTALL) -D -m 0644 $(@D)/fake-hwclock.8 \
		$(FAKE_HWCLOCK_TARGET_DIR)/usr/shared/man/man8/fake-hwclock.8
endef

$(eval $(generic-package))
