################################################################################
#
# thttpd
#
################################################################################

THTTPD_VERSION = 2.25b
THTTPD_SOURCE = thttpd_$(THTTPD_VERSION).orig.tar.gz
THTTPD_PATCH = thttpd_$(THTTPD_VERSION)-11.diff.gz
THTTPD_SITE = http://snapshot.debian.org/archive/debian/20141023T043132Z/pool/main/t/thttpd
THTTPD_LICENSE = BSD-2c
THTTPD_LICENSE_FILES = thttpd.c

ifneq ($(THTTPD_PATCH),)
define THTTPD_DEBIAN_PATCHES
	if [ -d $(@D)/debian/patches ]; then \
		$(APPLY_PATCHES) $(@D) $(@D)/debian/patches \*.patch; \
	fi
endef
endif

THTTPD_POST_PATCH_HOOKS = THTTPD_DEBIAN_PATCHES

THTTPD_MAKE = $(MAKE1)

define THTTPD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/thttpd $(THTTPD_TARGET_DIR)/usr/sbin/thttpd
	$(INSTALL) -D -m 0755 $(@D)/extras/htpasswd $(THTTPD_TARGET_DIR)/usr/bin/htpasswd
	$(INSTALL) -D -m 0755 $(@D)/extras/makeweb $(THTTPD_TARGET_DIR)/usr/bin/makeweb
	$(INSTALL) -D -m 0755 $(@D)/extras/syslogtocern $(THTTPD_TARGET_DIR)/usr/bin/syslogtocern
	$(INSTALL) -D -m 0755 $(@D)/scripts/thttpd_wrapper $(THTTPD_TARGET_DIR)/usr/sbin/thttpd_wrapper
	$(SED) 's:/usr/local/sbin:/usr/sbin:g' -e \
		's:/usr/local/www:/var/www:g' $(THTTPD_TARGET_DIR)/usr/sbin/thttpd_wrapper
	$(INSTALL) -d $(THTTPD_TARGET_DIR)/var/www/data
	$(INSTALL) -d $(THTTPD_TARGET_DIR)/var/www/logs
	echo "dir=/var/www/data" > $(THTTPD_TARGET_DIR)/var/www/thttpd_config
	echo 'cgipat=**.cgi' >> $(THTTPD_TARGET_DIR)/var/www/thttpd_config
	echo "logfile=/var/www/logs/thttpd_log" >> $(THTTPD_TARGET_DIR)/var/www/thttpd_config
	echo "pidfile=/var/run/thttpd.pid" >> $(THTTPD_TARGET_DIR)/var/www/thttpd_config
endef

define THTTPD_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(@D)/scripts/thttpd.sh $(THTTPD_TARGET_DIR)/etc/init.d/S90thttpd
	$(SED) 's:/usr/local/sbin:/usr/sbin:g' $(THTTPD_TARGET_DIR)/etc/init.d/S90thttpd
endef

$(eval $(autotools-package))
