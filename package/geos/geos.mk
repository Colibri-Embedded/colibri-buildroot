################################################################################
#
# geos
#
################################################################################

GEOS_VERSION = 3.5.0
GEOS_SITE = http://download.osgeo.org/geos
GEOS_SOURCE = geos-$(GEOS_VERSION).tar.bz2
GEOS_LICENSE = LGPL
GEOS_LICENSE_FILES = LICENSE
GEOS_INSTALL_STAGING = YES
#LIBFFI_AUTORECONF = YES

# Fix geos-config prefix and exec_prefix to go to $(STAGING_DIR) 
# so that packages can compile properly
define fix_geos_config
	sed -i $(STAGING_DIR)/usr/bin/geos-config -e 's@prefix=/usr@prefix=$(STAGING_DIR)/usr@'
	sed -i $(STAGING_DIR)/usr/bin/geos-config -e 's@exec_prefix=/usr@exec_prefix=$(STAGING_DIR)/usr@'
endef

GEOS_POST_INSTALL_TARGET_HOOKS += fix_geos_config

$(eval $(autotools-package))
$(eval $(host-autotools-package))
