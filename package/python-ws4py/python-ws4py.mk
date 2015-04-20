################################################################################
#
# python-ws4py
#
################################################################################

PYTHON_WS4PY_VERSION = 0.3.4
PYTHON_WS4PY_SOURCE = ws4py-$(PYTHON_WS4PY_VERSION).tar.gz
PYTHON_WS4PY_SITE = https://pypi.python.org/packages/source/w/ws4py
PYTHON_WS4PY_LICENSE = Python-2.0 (library), GPLv2+ (test)
PYTHON_WS4PY_LICENSE_FILES = LICENSE.PSF-2 LICENSE.GPL-2
PYTHON_WS4PY_SETUP_TYPE = setuptools

$(eval $(python-package))
