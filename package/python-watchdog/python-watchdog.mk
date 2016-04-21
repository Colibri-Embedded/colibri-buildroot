################################################################################
#
# python-daemon
#
################################################################################
PYTHON_WATCHDOG_VERSION = 0.8.3
PYTHON_WATCHDOG_SOURCE = watchdog-$(PYTHON_WATCHDOG_VERSION).tar.gz
PYTHON_WATCHDOG_SITE = https://pypi.python.org/packages/source/w/watchdog
PYTHON_WATCHDOG_LICENSE = Apache-2.0
PYTHON_WATCHDOG_LICENSE_FILES = LICENSE
PYTHON_WATCHDOG_SETUP_TYPE = setuptools

#BR2_PACKAGE_PYTHON_PYYAML

PYTHON_WATCHDOG_DEPENDENCIES = python-pyyaml

$(eval $(python-package))
