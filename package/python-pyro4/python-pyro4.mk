################################################################################
#
# python-pyro4
#
################################################################################

PYTHON_PYRO4_VERSION = 4.45
PYTHON_PYRO4_SOURCE = $(PYTHON_PYRO4_VERSION).tar.gz
PYTHON_PYRO4_SITE = https://github.com/irmen/Pyro4/archive/
PYTHON_PYRO4_LICENSE = MIT
PYTHON_PYRO4_LICENSE_FILES = LICENSE
PYTHON_PYRO4_SETUP_TYPE = setuptools
PYTHON_PYRO4_DEPENDENCIES = python-serpent python-selectors34 python-six

$(eval $(python-package))

#https://github.com/irmen/Pyro4/archive/4.45.tar.gz
