################################################################################
#
# python-serpent
#
################################################################################

PYTHON_SERPENT_VERSION = 1.12
PYTHON_SERPENT_SOURCE = serpent-$(PYTHON_SERPENT_VERSION).tar.gz
PYTHON_SERPENT_SITE = https://pypi.python.org/packages/source/s/serpent/
PYTHON_SERPENT_LICENSE = MIT
PYTHON_SERPENT_LICENSE_FILES = LICENSE
PYTHON_SERPENT_SETUP_TYPE = setuptools

PYTHON_SERPENT_INSTALL_STAGING = YES

$(eval $(python-package))
