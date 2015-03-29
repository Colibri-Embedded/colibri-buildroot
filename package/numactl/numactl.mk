################################################################################
#
# numactl
#
################################################################################

NUMACTL_VERSION = 2.0.9
NUMACTL_SITE = ftp://oss.sgi.com/www/projects/libnuma/download
NUMACTL_LICENSE = LGPLv2.1 (libnuma), GPLv2 (programs)
NUMACTL_LICENSE_FILES = README

define NUMACTL_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define NUMACTL_INSTALL_TARGET_CMDS
	$(MAKE) prefix=$(NUMACTL_TARGET_DIR) libdir=$(NUMACTL_TARGET_DIR)/lib -C $(@D) install
endef

$(eval $(generic-package))
