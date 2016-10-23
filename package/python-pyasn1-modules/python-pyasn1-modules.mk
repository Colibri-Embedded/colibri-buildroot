################################################################################
#
# python-pyasn1-modules
#
################################################################################

PYTHON_PYASN1_MODULES_VERSION = 0.0.8
PYTHON_PYASN1_MODULES_SOURCE = pyasn1-modules-$(PYTHON_PYASN1_MODULES_VERSION).tar.gz
PYTHON_PYASN1_MODULES_SITE =  https://sourceforge.net/projects/pyasn1/files/pyasn1/$(PYTHON_PYASN1_VERSION)/
PYTHON_PYASN1_MODULES_LICENSE = MIT
PYTHON_PYASN1_MODULES_LICENSE_FILES = LICENSE
PYTHON_PYASN1_MODULES_SETUP_TYPE = setuptools

$(eval $(python-package))
