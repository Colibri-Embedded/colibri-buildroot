################################################################################
#
# python-service-identity
#
################################################################################

PYTHON_SERVICE_IDENTITY_VERSION = 16.0.0
PYTHON_SERVICE_IDENTITY_SOURCE = $(PYTHON_SERVICE_IDENTITY_VERSION).tar.gz
PYTHON_SERVICE_IDENTITY_SITE = https://github.com/pyca/service_identity/archive/
PYTHON_SERVICE_IDENTITY_LICENSE = MIT
PYTHON_SERVICE_IDENTITY_LICENSE_FILES = LICENSE
PYTHON_SERVICE_IDENTITY_SETUP_TYPE = setuptools
PYTHON_SERVICE_IDENTITY_DEPENDENCIES = python-attrs python-pyasn1 python-pyasn1-modules python-pyopenssl

$(eval $(python-package))
