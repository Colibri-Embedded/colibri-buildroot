################################################################################
#
# python-pynacl
#
################################################################################

PYTHON_PYNACL_VERSION = 1.0.1
PYTHON_PYNACL_SOURCE = PyNaCl-$(PYTHON_PYNACL_VERSION).tar.gz
PYTHON_PYNACL_SITE = https://pypi.python.org/packages/dd/99/bc86d40c88c1e1c6c9338d5afa91e3126d1ae28ad1bdfac79ab5b01803df
PYTHON_PYNACL_LICENSE = MIT
PYTHON_PYNACL_LICENSE_FILES = LICENSE
PYTHON_PYNACL_SETUP_TYPE = setuptools
PYTHON_PYNACL_DEPENDENCIES = host-python-cffi libffi libsodium

PYTHON_PYNACL_ENV = SODIUM_INSTALL="system"

$(eval $(python-package))
