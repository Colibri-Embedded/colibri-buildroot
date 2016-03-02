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

$(eval $(python-package))
