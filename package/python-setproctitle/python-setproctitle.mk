################################################################################
#
# python-setproctitle
#
################################################################################

PYTHON_SETPROCTITLE_VERSION = 1.1.10
PYTHON_SETPROCTITLE_SOURCE = version-$(PYTHON_SETPROCTITLE_VERSION).tar.gz
PYTHON_SETPROCTITLE_SITE = https://github.com/dvarrazzo/py-setproctitle/archive/
PYTHON_SETPROCTITLE_LICENSE = BSD-3-Clause
PYTHON_SETPROCTITLE_LICENSE_FILES = COPYRIGHT
PYTHON_SETPROCTITLE_SETUP_TYPE = setuptools

$(eval $(python-package))
