################################################################################
#
# python-txaio
#
################################################################################

PYTHON_TXAIO_VERSION = 2.5.1
PYTHON_TXAIO_SOURCE = v$(PYTHON_TXAIO_VERSION).tar.gz
PYTHON_TXAIO_SITE = https://github.com/crossbario/txaio/archive
PYTHON_TXAIO_LICENSE = MIT
PYTHON_TXAIO_SETUP_TYPE = setuptools

$(eval $(python-package))
