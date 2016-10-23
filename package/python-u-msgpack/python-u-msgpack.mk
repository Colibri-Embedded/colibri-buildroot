################################################################################
#
# python-u-msgpack
#
################################################################################

PYTHON_U_MSGPACK_VERSION = 2.3.0
PYTHON_U_MSGPACK_SOURCE = v$(PYTHON_U_MSGPACK_VERSION).tar.gz
PYTHON_U_MSGPACK_SITE = https://github.com/vsergeev/u-msgpack-python/archive/
PYTHON_U_MSGPACK_LICENSE = MIT
PYTHON_U_MSGPACK_LICENSE_FILES = LICENSE
PYTHON_U_MSGPACK_SETUP_TYPE = setuptools
#PYTHON_U_MSGPACK_DEPENDENCIES = 

$(eval $(python-package))
