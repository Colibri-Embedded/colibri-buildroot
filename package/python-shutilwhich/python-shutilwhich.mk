################################################################################
#
# python-shutilwhich
#
################################################################################

PYTHON_SHUTILWHICH_VERSION = 1.1.0
PYTHON_SHUTILWHICH_SOURCE = $(PYTHON_SHUTILWHICH_VERSION).tar.gz
PYTHON_SHUTILWHICH_SITE = https://github.com/mbr/shutilwhich/archive/
PYTHON_SHUTILWHICH_LICENSE = MIT
PYTHON_SHUTILWHICH_LICENSE_FILES = LICENSE
PYTHON_SHUTILWHICH_SETUP_TYPE = setuptools
#PYTHON_SHUTILWHICH_DEPENDENCIES = 

$(eval $(python-package))
