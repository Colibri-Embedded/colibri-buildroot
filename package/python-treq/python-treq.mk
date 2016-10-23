################################################################################
#
# python-treq
#
################################################################################
PYTHON_TREQ_VERSION = 15.1.0
PYTHON_TREQ_SOURCE = treq-$(PYTHON_TREQ_VERSION).tar.gz
PYTHON_TREQ_SITE = https://pypi.python.org/packages/db/ef/c112eae4e9d165f4664f5d25949cb832ab4e1bc255d19e7dad81342d486d
PYTHON_TREQ_LICENSE = MIT
PYTHON_TREQ_LICENSE_FILES = LICENSE
PYTHON_TREQ_SETUP_TYPE = setuptools
PYTHON_TREQ_DEPENDENCIES = python-twisted python-requests python-pyopenssl python-service-identity

$(eval $(python-package))
