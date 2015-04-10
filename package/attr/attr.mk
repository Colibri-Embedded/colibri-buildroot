################################################################################
#
# attr
#
################################################################################

ATTR_VERSION = 2.4.47
ATTR_SOURCE = attr-$(ATTR_VERSION).src.tar.gz
ATTR_SITE = http://download.savannah.gnu.org/releases/attr
ATTR_INSTALL_STAGING = YES
ATTR_CONF_OPTS = --enable-gettext=no
ATTR_LICENSE = GPLv2+ (programs), LGPLv2.1+ (libraries)
ATTR_LICENSE_FILES = doc/COPYING doc/COPYING.LGPL

# While the configuration system uses autoconf, the Makefiles are
# hand-written and do not use automake. Therefore, we have to hack
# around their deficiencies by passing installation paths.
ATTR_INSTALL_STAGING_OPTS = 			\
	prefix=$(STAGING_DIR)/usr 		\
	exec_prefix=$(STAGING_DIR)/usr 		\
	PKG_DEVLIB_DIR=$(STAGING_DIR)/usr/lib 	\
	install-dev install-lib

ATTR_INSTALL_TARGET_OPTS = 			\
	prefix=$(ATTR_TARGET_DIR)/usr 		\
	exec_prefix=$(ATTR_TARGET_DIR)/usr 		\
	install install-lib
	
HOST_ATTR_INSTALL_OPTS = 	\
	prefix=$(HOST_DIR)/usr 		\
	exec_prefix=$(HOST_DIR)/usr		\
	PKG_DEVLIB_DIR=$(HOST_DIR)/usr/lib 	\
	install-dev install-lib

$(eval $(autotools-package))
$(eval $(host-autotools-package))
