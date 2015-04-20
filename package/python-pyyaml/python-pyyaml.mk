################################################################################
#
# python-pyyaml
#
################################################################################

PYTHON_PYYAML_VERSION = 3.11
PYTHON_PYYAML_SOURCE = PyYAML-$(PYTHON_PYYAML_VERSION).tar.gz
PYTHON_PYYAML_SITE = http://pyyaml.org/download/pyyaml
PYTHON_PYYAML_LICENSE = Public Domain
PYTHON_PYYAML_LICENSE_FILES = LICENSE
PYTHON_PYYAML_SETUP_TYPE = distutils
PYTHON_PYYAML_DEPENDENCIES = libyaml

PYTHON_PYYAML_INSTALL_STAGING = YES

$(eval $(python-package))
