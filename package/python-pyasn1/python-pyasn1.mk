################################################################################
#
# python-pyasn1
#
################################################################################

PYTHON_PYASN1_VERSION = 0.1.9
PYTHON_PYASN1_SOURCE = pyasn1-$(PYTHON_PYASN1_VERSION).tar.gz
PYTHON_PYASN1_SITE =  https://sourceforge.net/projects/pyasn1/files/pyasn1/$(PYTHON_PYASN1_VERSION)/
PYTHON_PYASN1_LICENSE = MIT
PYTHON_PYASN1_LICENSE_FILES = LICENSE
PYTHON_PYASN1_SETUP_TYPE = setuptools

$(eval $(python-package))
