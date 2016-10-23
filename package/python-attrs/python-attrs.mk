################################################################################
#
# python-attrs
#
################################################################################

PYTHON_ATTRS_VERSION = 16.2.0
PYTHON_ATTRS_SOURCE = $(PYTHON_ATTRS_VERSION).tar.gz
PYTHON_ATTRS_SITE = https://github.com/hynek/attrs/archive/
PYTHON_ATTRS_LICENSE = MIT
PYTHON_ATTRS_LICENSE_FILES = LICENSE
PYTHON_ATTRS_SETUP_TYPE = setuptools

$(eval $(python-package))
