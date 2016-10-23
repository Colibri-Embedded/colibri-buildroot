################################################################################
#
# python-netaddr
#
################################################################################

PYTHON_NETADDR_VERSION = 0.7.18
PYTHON_NETADDR_SOURCE = netaddr-$(PYTHON_NETADDR_VERSION).tar.gz
PYTHON_NETADDR_SITE = https://github.com/drkjam/netaddr/archive/
PYTHON_NETADDR_LICENSE = BSD-3-Clause
PYTHON_NETADDR_LICENSE_FILES = LICENSE
PYTHON_NETADDR_SETUP_TYPE = distutils
#PYTHON_NETADDR_DEPENDENCIES = 

$(eval $(python-package))
