################################################################################
#
# python-txdbus
#
################################################################################

PYTHON_TXDBUS_VERSION = 1.0.14
PYTHON_TXDBUS_SOURCE = $(PYTHON_TXDBUS_VERSION).tar.gz
PYTHON_TXDBUS_SITE = https://github.com/cocagne/txdbus/archive/
PYTHON_TXDBUS_LICENSE = BSD-3c
PYTHON_TXDBUS_LICENSE_FILES = LICENSE.txt
PYTHON_TXDBUS_SETUP_TYPE = setuptools
PYTHON_TXDBUS_DEPENDENCIES = python-twisted

$(eval $(python-package))
