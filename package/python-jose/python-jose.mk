################################################################################
#
# python-jose
#
################################################################################

PYTHON_JOSE_VERSION = 1.3.2
PYTHON_JOSE_SOURCE = $(PYTHON_JOSE_VERSION).tar.gz
PYTHON_JOSE_SITE = https://github.com/mpdavis/python-jose/archive
PYTHON_JOSE_SETUP_TYPE = setuptools
PYTHON_JOSE_LICENSE = MIT
PYTHON_JOSE_LICENSE_FILES = LICENSE
PYTHON_JOSE_DEPENDENCIES = python-pycrypto python-six

$(eval $(python-package))
$(eval $(host-python-package))
