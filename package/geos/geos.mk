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

$(eval $(autotools-package))
$(eval $(host-autotools-package))
