################################################################################
#
# start-stop-daemon
#
################################################################################

# Debian start-stop-daemon is part of dpkg. Since start-stop-daemon is the only
# interesting tool in it, we call the buildroot package start-stop-daemon.

START_STOP_DAEMON_VERSION = 1.16.15
START_STOP_DAEMON_SOURCE = dpkg_$(START_STOP_DAEMON_VERSION).tar.xz
START_STOP_DAEMON_SITE = http://snapshot.debian.org/archive/debian/20140616T044945Z/pool/main/d/dpkg
START_STOP_DAEMON_CONF_OPTS = \
	--disable-dselect \
	--disable-update-alternatives \
	--disable-install-info \
	--exec-prefix=/
START_STOP_DAEMON_CONF_ENV = \
	dpkg_cv_va_copy=yes \
	dpkg_cv_c99_snprintf=yes
START_STOP_DAEMON_DEPENDENCIES = host-pkgconf \
	$(if $(BR2_PACKAGE_BUSYBOX),busybox)
# Patching m4/dpkg-arch.m4
START_STOP_DAEMON_AUTORECONF = YES
START_STOP_DAEMON_LICENSE = GPLv2+
START_STOP_DAEMON_LICENSE_FILES = COPYING

define START_STOP_DAEMON_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/lib/compat
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/utils
endef

define START_STOP_DAEMON_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/utils/start-stop-daemon \
		$(START_STOP_DAEMON_TARGET_DIR)/sbin/start-stop-daemon
endef

$(eval $(autotools-package))
