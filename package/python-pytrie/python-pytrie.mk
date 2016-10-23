################################################################################
#
# python-pytrie
#
################################################################################

PYTHON_PYTRIE_VERSION = 0.2
PYTHON_PYTRIE_SOURCE = PyTrie-$(PYTHON_PYTRIE_VERSION).tar.gz
PYTHON_PYTRIE_SITE = https://pypi.python.org/packages/bb/a4/b2e9f63ec9853777f77a22336020aa610233ba0678cdb7c2e63bd198fac7/
PYTHON_PYTRIE_LICENSE = BSD
PYTHON_PYTRIE_LICENSE_FILES = LICENSE
PYTHON_PYTRIE_SETUP_TYPE = distutils
#PYTHON_PYTRIE_DEPENDENCIES = 

$(eval $(python-package))
