################################################################################
#
# python-pyconnman
#
################################################################################

PYTHON_PYCONNMAN_VERSION = 0.1.0
PYTHON_PYCONNMAN_SOURCE = $(PYTHON_PYCONNMAN_VERSION).tar.gz
PYTHON_PYCONNMAN_SITE =  https://github.com/liamw9534/pyconnman/archive
PYTHON_PYCONNMAN_LICENSE = BSD-3c
PYTHON_PYCONNMAN_LICENSE_FILES = LICENSE.txt
PYTHON_PYCONNMAN_SETUP_TYPE = setuptools
PYTHON_PYCONNMAN_DEPENDENCIES = dbus-python

$(eval $(python-package))
