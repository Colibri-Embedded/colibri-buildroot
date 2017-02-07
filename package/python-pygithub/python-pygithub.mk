################################################################################
#
# python-pygithub
#
################################################################################

PYTHON_PYGITHUB_VERSION = 1.32
PYTHON_PYGITHUB_SOURCE = v$(PYTHON_PYGITHUB_VERSION).tar.gz
PYTHON_PYGITHUB_SITE = https://github.com/PyGithub/PyGithub/archive/
PYTHON_PYGITHUB_SETUP_TYPE = setuptools
PYTHON_PYGITHUB_LICENSE = GPLv3
PYTHON_PYGITHUB_LICENSE_FILES = COPYING
PYTHON_PYGITHUB_DEPENDENCIES = python-jose

$(eval $(python-package))
$(eval $(host-python-package))
