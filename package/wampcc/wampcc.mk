################################################################################
#
# wampcc
#
################################################################################

#WAMPCC_VERSION = 1.4.1
WAMPCC_VERSION = be447e129acf14b311bbb90c15e9d52cb17d8cdc
WAMPCC_SITE = $(call github,infinity0n3,wampcc,$(WAMPCC_VERSION))
WAMPCC_LICENSE = MIT
WAMPCC_LICENSE_FILES = LICENSE
WAMPCC_INSTALL_STAGING = YES

$(eval $(cmake-package))
