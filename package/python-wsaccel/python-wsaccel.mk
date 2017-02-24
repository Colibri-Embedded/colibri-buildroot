################################################################################
#
# python-wsaccel
#
################################################################################

PYTHON_WSACCEL_VERSION = 0.6.2
PYTHON_WSACCEL_SOURCE = wsaccel-$(PYTHON_WSACCEL_VERSION).tar.gz
PYTHON_WSACCEL_SITE = https://pypi.python.org/packages/52/46/9ef0744b434ac723ae3aeddcb92ab29af14f8912f53f47590b5a0db0b9d6/
PYTHON_WSACCEL_LICENSE = MIT
PYTHON_WSACCEL_LICENSE_FILES = LICENSE
PYTHON_WSACCEL_SETUP_TYPE = setuptools
#PYTHON_WSACCEL_DEPENDENCIES = 

$(eval $(python-package))
