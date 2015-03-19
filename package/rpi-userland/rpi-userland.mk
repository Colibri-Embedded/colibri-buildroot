################################################################################
#
# rpi-userland
#
################################################################################

RPI_USERLAND_VERSION = ba753c1a7f68d7a2e00edaf03364eef001e233ef
RPI_USERLAND_SITE = $(call github,raspberrypi,userland,$(RPI_USERLAND_VERSION))
RPI_USERLAND_LICENSE = BSD-3c
RPI_USERLAND_LICENSE_FILES = LICENCE
RPI_USERLAND_INSTALL_STAGING = YES
RPI_USERLAND_CONF_OPTS = -DVMCS_INSTALL_PREFIX=/usr \
	-DCMAKE_C_FLAGS="-DVCFILED_LOCKFILE=\\\"/var/run/vcfiled.pid\\\""

RPI_USERLAND_PROVIDES = libegl libgles libopenmax libopenvg

ifeq ($(BR2_PACKAGE_RPI_USERLAND_START_VCFILED),y)
define RPI_USERLAND_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D package/rpi-userland/S94vcfiled \
		$(RPI_USERLAND)/etc/init.d/S94vcfiled
endef
endif

define RPI_USERLAND_POST_TARGET_CLEANUP
	rm -f $(RPI_USERLAND)/etc/init.d/vcfiled
	rm -f $(RPI_USERLAND)/usr/share/install/vcfiled
	rmdir --ignore-fail-on-non-empty $(RPI_USERLAND)/usr/share/install
	rm -Rf $(RPI_USERLAND)/usr/src
endef
RPI_USERLAND_POST_INSTALL_TARGET_HOOKS += RPI_USERLAND_POST_TARGET_CLEANUP

$(eval $(cmake-package))
