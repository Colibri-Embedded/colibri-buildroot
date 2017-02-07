################################################################################
#
# python-ecdsa
#
################################################################################

PYTHON_ECDSA_VERSION = 0.13
PYTHON_ECDSA_SOURCE = python-ecdsa-$(PYTHON_ECDSA_VERSION).tar.gz
PYTHON_ECDSA_SITE = https://github.com/warner/python-ecdsa/archive/
PYTHON_ECDSA_SETUP_TYPE = setuptools
PYTHON_ECDSA_LICENSE = MIT
PYTHON_ECDSA_LICENSE_FILES = LICENSE
PYTHON_ECDSA_DEPENDENCIES = python-six

$(eval $(python-package))
$(eval $(host-python-package))
