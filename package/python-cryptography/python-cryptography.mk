################################################################################
#
# python-cryptography
#
################################################################################

PYTHON_CRYPTOGRAPHY_VERSION = 1.5.2
PYTHON_CRYPTOGRAPHY_SOURCE = $(PYTHON_CRYPTOGRAPHY_VERSION).tar.gz
PYTHON_CRYPTOGRAPHY_SITE = https://github.com/pyca/cryptography/archive/
PYTHON_CRYPTOGRAPHY_LICENSE = MIT
PYTHON_CRYPTOGRAPHY_LICENSE_FILES = LICENSE
PYTHON_CRYPTOGRAPHY_SETUP_TYPE = setuptools
PYTHON_CRYPTOGRAPHY_DEPENDENCIES = host-python-cffi python-cffi python-idna

$(eval $(python-package))
