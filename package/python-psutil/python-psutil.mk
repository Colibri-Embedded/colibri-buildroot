################################################################################
#
# python-psutil
#
################################################################################

PYTHON_PSUTIL_VERSION = 4.4.0
PYTHON_PSUTIL_SOURCE = release-$(PYTHON_PSUTIL_VERSION).tar.gz
PYTHON_PSUTIL_SITE = https://github.com/giampaolo/psutil/archive/
PYTHON_PSUTIL_SETUP_TYPE = setuptools
PYTHON_PSUTIL_LICENSE = BSD-3c
PYTHON_PSUTIL_LICENSE_FILES = LICENSE

$(eval $(python-package))
