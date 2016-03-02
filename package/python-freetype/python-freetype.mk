################################################################################
#
# python-freetype
#
################################################################################

PYTHON_FREETYPE_VERSION = 1.0.2
PYTHON_FREETYPE_SOURCE = freetype-py-$(PYTHON_FREETYPE_VERSION).tar.gz
PYTHON_FREETYPE_SITE = https://pypi.python.org/packages/source/f/freetype-py
PYTHON_FREETYPE_LICENSE = Python-2.0 (library), GPLv2+ (test)
PYTHON_FREETYPE_LICENSE_FILES = LICENSE.PSF-2 LICENSE.GPL-2
PYTHON_FREETYPE_SETUP_TYPE = setuptools
PYTHON_FREETYPE_DEPENDENCIES = freetype

$(eval $(python-package))
