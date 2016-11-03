################################################################################
#
# rng-tools
#
################################################################################

RNG_TOOLS_VERSION = 5
RNG_TOOLS_SITE = http://downloads.sourceforge.net/project/gkernel/rng-tools/$(RNG_TOOLS_VERSION)
RNG_TOOLS_LICENSE = GPLv2
RNG_TOOLS_LICENSE_FILES = COPYING

# Work around for uClibc's lack of argp_*() functions
ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
RNG_TOOLS_CONF_ENV += LIBS="-largp"
RNG_TOOLS_DEPENDENCIES += argp-standalone
endif

ifeq ($(BR2_PACKAGE_LIBGCRYPT),y)
RNG_TOOLS_DEPENDENCIES += libgcrypt
else
RNG_TOOLS_CONF_OPTS += --without-libgcrypt
endif


define RNG_TOOLS_INSTALL_INIT_SYSV
	$(RNG_TOOLS_FAKEROOT) $(RNG_TOOLS_FAKEROOT_ENV) $(INSTALL) -D -m 0755 package/rng-tools/rngd.init \
		$(RNG_TOOLS_TARGET_DIR)/etc/init.d/rngd
	$(RNG_TOOLS_FAKEROOT) $(RNG_TOOLS_FAKEROOT_ENV) $(INSTALL) -D -m 0644 package/rng-tools/rngd.default \
		$(RNG_TOOLS_TARGET_DIR)/etc/default/dnsmasq
		
	$(RNG_TOOLS_FAKEROOT) $(RNG_TOOLS_FAKEROOT_ENV) $(INSTALL) -d -m 0755 $(RNG_TOOLS_TARGET_DIR)/etc/rc.d/rc.sysinit.d
	$(RNG_TOOLS_FAKEROOT) $(RNG_TOOLS_FAKEROOT_ENV) $(INSTALL) -d -m 0755 $(RNG_TOOLS_TARGET_DIR)/etc/rc.d/rc.shutdown.d
	
	$(RNG_TOOLS_FAKEROOT) $(RNG_TOOLS_FAKEROOT_ENV) ln -fs ../../init.d/rngd \
		$(RNG_TOOLS_TARGET_DIR)/etc/rc.d/rc.sysinit.d/S40rngd
	$(RNG_TOOLS_FAKEROOT) $(RNG_TOOLS_FAKEROOT_ENV) ln -fs ../../init.d/rngd \
		$(RNG_TOOLS_TARGET_DIR)/etc/rc.d/rc.shutdown.d/S40rngd
endef

$(eval $(autotools-package))
