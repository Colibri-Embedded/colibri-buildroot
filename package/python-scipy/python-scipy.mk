################################################################################
#
# python-scipy
#
################################################################################

PYTHON_SCIPY_VERSION = 0.15.0
PYTHON_SCIPY_SOURCE = scipy-$(PYTHON_SCIPY_VERSION).tar.gz
PYTHON_SCIPY_SITE = https://pypi.python.org/packages/source/s/scipy
PYTHON_SCIPY_LICENSE = BSD-3c
PYTHON_SCIPY_LICENSE_FILES = LICENSE.txt
PYTHON_SCIPY_SETUP_TYPE = distutils
PYTHON_SCIPY_DEPENDENCIES = host-python-numpy python-numpy clapack

PYTHON_SCIPY_BUILD_OPTS = --fcompiler=gnu95

$(eval $(python-package))
