################################################################################
#
# python-lmdb
#
################################################################################

PYTHON_LMDB_VERSION = 0.92
PYTHON_LMDB_SOURCE = py-lmdb_$(PYTHON_LMDB_VERSION).tar.gz
PYTHON_LMDB_SITE = https://github.com/dw/py-lmdb/archive/
PYTHON_LMDB_LICENSE = MIT
PYTHON_LMDB_LICENSE_FILES = LICENSE
PYTHON_LMDB_SETUP_TYPE = setuptools
#PYTHON_LMDB_DEPENDENCIES = 

$(eval $(python-package))
