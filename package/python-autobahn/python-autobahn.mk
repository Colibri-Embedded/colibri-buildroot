################################################################################
#
# python-autobahn
#
################################################################################

PYTHON_AUTOBAHN_VERSION = 0.16.0
PYTHON_AUTOBAHN_SOURCE = v$(PYTHON_AUTOBAHN_VERSION).tar.gz
PYTHON_AUTOBAHN_SITE = https://github.com/crossbario/autobahn-python/archive/
PYTHON_AUTOBAHN_LICENSE = MIT
# README.rst refers to the file "LICENSE" but it's not included
PYTHON_AUTOBAHN_SETUP_TYPE = setuptools
PYTHON_AUTOBAHN_DEPENDENCIES = python-txaio

$(eval $(python-package))
