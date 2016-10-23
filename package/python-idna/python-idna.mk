################################################################################
#
# python-idna
#
################################################################################

PYTHON_IDNA_VERSION = 2.1
PYTHON_IDNA_SOURCE = v$(PYTHON_IDNA_VERSION).tar.gz
PYTHON_IDNA_SITE = https://github.com/kjd/idna/archive/
PYTHON_IDNA_LICENSE = Mixed
PYTHON_IDNA_LICENSE_FILES = LICENSE
PYTHON_IDNA_SETUP_TYPE = setuptools
#PYTHON_IDNA_DEPENDENCIES = 

$(eval $(python-package))
