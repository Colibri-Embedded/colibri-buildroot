################################################################################
#
# wampcc
#
################################################################################

#WAMPCC_VERSION = 1.4.1
WAMPCC_VERSION = 47c1baa73cdce72a3fd02c1071b7976aabdf62fc
WAMPCC_SITE = $(call github,infinity0n3,wampcc,$(WAMPCC_VERSION))
WAMPCC_LICENSE = MIT
WAMPCC_LICENSE_FILES = LICENSE
WAMPCC_INSTALL_STAGING = YES

$(eval $(cmake-package))
