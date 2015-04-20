################################################################################
#
# python-pathtools
#
################################################################################
PYTHON_PATHTOOLS_VERSION =0.1.2
PYTHON_PATHTOOLS_SOURCE = pathtools-$(PYTHON_PATHTOOLS_VERSION).tar.gz
PYTHON_PATHTOOLS_SITE = https://pypi.python.org/packages/source/p/pathtools/
PYTHON_PATHTOOLS_LICENSE = Python-2.0 (library), GPLv2+ (test)
PYTHON_PATHTOOLS_LICENSE_FILES = LICENSE.PSF-2 LICENSE.GPL-2
PYTHON_PATHTOOLS_SETUP_TYPE = setuptools

PYTHON_PYYAML_INSTALL_STAGING = YES

$(eval $(python-package))
