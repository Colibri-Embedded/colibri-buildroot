################################################################################
#
# python-selectors34
#
################################################################################

PYTHON_SELECTORS34_VERSION = 1.1
PYTHON_SELECTORS34_SOURCE = selectors34-$(PYTHON_SELECTORS34_VERSION).tar.gz
PYTHON_SELECTORS34_SITE = https://pypi.python.org/packages/source/s/selectors34/
PYTHON_SELECTORS34_LICENSE = MIT
PYTHON_SELECTORS34_LICENSE_FILES = LICENSE
PYTHON_SELECTORS34_SETUP_TYPE = setuptools
PYTHON_SELECTORS34_DEPENDENCIES = python-six

PYTHON_SELECTORS34_INSTALL_STAGING = YES

$(eval $(python-package))
