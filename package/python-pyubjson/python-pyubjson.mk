################################################################################
#
# python-pyubjson
#
################################################################################

PYTHON_PYUBJSON_VERSION = 0.8.5
PYTHON_PYUBJSON_SOURCE = v$(PYTHON_PYUBJSON_VERSION).tar.gz
PYTHON_PYUBJSON_SITE = https://github.com/Iotic-Labs/py-ubjson/archive/
PYTHON_PYUBJSON_LICENSE = MIT
PYTHON_PYUBJSON_LICENSE_FILES = LICENSE
PYTHON_PYUBJSON_SETUP_TYPE = setuptools
#PYTHON_PYUBJSON_DEPENDENCIES = 

$(eval $(python-package))
