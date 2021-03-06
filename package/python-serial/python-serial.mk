################################################################################
#
# python-serial
#
################################################################################

PYTHON_SERIAL_VERSION = 3.0.1
PYTHON_SERIAL_SOURCE = pyserial-$(PYTHON_SERIAL_VERSION).tar.gz
PYTHON_SERIAL_SITE = http://pypi.python.org/packages/source/p/pyserial
PYTHON_SERIAL_LICENSE = BSD-3c
PYTHON_SERIAL_LICENSE_FILES = LICENSE.txt
PYTHON_SERIAL_SETUP_TYPE = setuptools

$(eval $(python-package))
