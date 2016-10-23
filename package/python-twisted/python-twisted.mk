################################################################################
#
# python-twisted
#
################################################################################

PYTHON_TWISTED_VERSION_MAJOR   = 16.4
PYTHON_TWISTED_VERSION_RELEASE = 1
PYTHON_TWISTED_SOURCE = Twisted-$(PYTHON_TWISTED_VERSION_MAJOR).$(PYTHON_TWISTED_VERSION_RELEASE).tar.bz2
PYTHON_TWISTED_SITE = https://twistedmatrix.com/Releases/Twisted/$(PYTHON_TWISTED_VERSION_MAJOR)/
PYTHON_TWISTED_SETUP_TYPE = setuptools
PYTHON_TWISTED_LICENSE = MIT
PYTHON_TWISTED_LICENSE_FILES = LICENSE

$(eval $(python-package))
