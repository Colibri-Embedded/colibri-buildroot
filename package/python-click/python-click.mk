################################################################################
#
# python-click
#
################################################################################

PYTHON_CLICK_VERSION = 6.6
PYTHON_CLICK_SOURCE = $(PYTHON_CLICK_VERSION).tar.gz
PYTHON_CLICK_SITE = https://github.com/pallets/click/archive/
PYTHON_CLICK_LICENSE = BSD-3-Clause
PYTHON_CLICK_LICENSE_FILES = LICENSE
PYTHON_CLICK_SETUP_TYPE = setuptools
#PYTHON_CLICK_DEPENDENCIES = 

$(eval $(python-package))
