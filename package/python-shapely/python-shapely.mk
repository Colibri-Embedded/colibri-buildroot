################################################################################
#
# python-shapely
#
################################################################################

PYTHON_SHAPELY_VERSION = 1.5.13
PYTHON_SHAPELY_SOURCE = Shapely-$(PYTHON_SHAPELY_VERSION).tar.gz
PYTHON_SHAPELY_SITE = https://pypi.python.org/packages/source/S/Shapely
PYTHON_SHAPELY_LICENSE = Python-2.0 (library), BSD
PYTHON_SHAPELY_LICENSE_FILES = LICENSE.PSF-2 LICENSE.GPL-2
PYTHON_SHAPELY_DEPENDENCIES = geos
PYTHON_SHAPELY_SETUP_TYPE = setuptools
#~ PYTHON_SHAPELY_SETUP_TYPE = distutils

# Allow python-shapely to find geos-config
PYTHON_SHAPELY_ENV += GEOS_CONFIG=$(STAGING_DIR)/usr/bin/geos-config

define mk_site_directory
	$(PYTHON_SHAPELY_FAKEROOT) mkdir -p $(PYTHON_SHAPELY_TARGET_DIR)/usr/lib/python$(SELECTED_PYTHON_VERSION_MAJOR)/site-packages
endef

PYTHON_SHAPELY_PRE_INSTALL_TARGET_HOOKS 	+= mk_site_directory

$(eval $(python-package))
