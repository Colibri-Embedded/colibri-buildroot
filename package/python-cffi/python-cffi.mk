################################################################################
#
# python-cffi
#
################################################################################

PYTHON_CFFI_VERSION = 1.7.0
PYTHON_CFFI_SOURCE = cffi-$(PYTHON_CFFI_VERSION).tar.gz
#~ PYTHON_CFFI_SITE = https://pypi.python.org/packages/source/c/cffi
PYTHON_CFFI_SITE = https://pypi.python.org/packages/83/3c/00b553fd05ae32f27b3637f705c413c4ce71290aa9b4c4764df694e906d9
PYTHON_CFFI_SETUP_TYPE = setuptools
PYTHON_CFFI_DEPENDENCIES = host-pkgconf libffi python-pycparser
PYTHON_CFFI_LICENSE = MIT
PYTHON_CFFI_LICENSE_FILES = LICENSE

$(eval $(python-package))
