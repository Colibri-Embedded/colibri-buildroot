################################################################################
#
# ntp
#
################################################################################

NTP_VERSION_MAJOR = 4.2
NTP_VERSION = $(NTP_VERSION_MAJOR).8p1
NTP_SITE = http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-$(NTP_VERSION_MAJOR)
NTP_DEPENDENCIES = host-pkgconf libevent
NTP_LICENSE = ntp license
NTP_LICENSE_FILES = COPYRIGHT
NTP_CONF_ENV = ac_cv_lib_md5_MD5Init=no
NTP_CONF_OPTS = \
	--with-shared \
	--program-transform-name=s,,, \
	--disable-tickadj \
	--with-yielding-select=yes \
	--disable-local-libevent

ifneq ($(BR2_INET_IPV6),y)
	NTP_CONF_ENV += isc_cv_have_in6addr_any=no
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
	NTP_CONF_OPTS += --with-crypto
	NTP_DEPENDENCIES += openssl
else
	NTP_CONF_OPTS += --without-crypto --disable-openssl-random
endif

ifeq ($(BR2_PACKAGE_NTP_NTPSNMPD),y)
	NTP_CONF_OPTS += \
		--with-net-snmp-config=$(STAGING_DIR)/usr/bin/net-snmp-config
	NTP_DEPENDENCIES += netsnmp
else
	NTP_CONF_OPTS += --without-ntpsnmpd
endif

ifeq ($(BR2_PACKAGE_NTP_NTPD_ATOM_PPS),y)
	NTP_CONF_OPTS += --enable-ATOM
	NTP_DEPENDENCIES += pps-tools
else
	NTP_CONF_OPTS += --disable-ATOM
endif

define NTP_PATCH_FIXUPS
	$(SED) "s,^#if.*__GLIBC__.*_BSD_SOURCE.*$$,#if 0," $(@D)/ntpd/refclock_pcf.c
	$(SED) '/[[:space:](]rindex[[:space:]]*(/s/[[:space:]]*rindex[[:space:]]*(/ strrchr(/g' $(@D)/ntpd/*.c
endef

#~ NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTP_KEYGEN) += util/ntp-keygen
#~ NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTP_WAIT) += scripts/ntp-wait/ntp-wait
#~ NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTPDATE) += ntpdate/ntpdate
#~ NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTPDC) += ntpdc/ntpdc
#~ NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTPQ) += ntpq/ntpq
#~ NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTPSNMPD) += ntpsnmpd/ntpsnmpd
#~ NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTPTRACE) += scripts/ntptrace/ntptrace
#~ NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_SNTP) += sntp/sntp
#~ NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_TICKADJ) += util/tickadj

NTP_INSTALL_FILES_								+= calc_tickadj
NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTP_KEYGEN) += ntp-keygen
NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTP_WAIT) += ntp-wait
NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTPDATE) += ntpdate
NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTPDC) += ntpdc
NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTPQ) += ntpq
NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTPSNMPD) += ntpsnmpd
NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_NTPTRACE) += ntptrace
NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_SNTP) += sntp
NTP_INSTALL_FILES_$(BR2_PACKAGE_NTP_TICKADJ) += tickadj

define NTP_REMOVE_UNWANTED_FILES
	for f in $(NTP_INSTALL_FILES_); do \
		if [ -e $(NTP_TARGET_DIR)/usr/bin/$$f ]; then \
			$(NTP_FAKEROOT) rm -f $(NTP_TARGET_DIR)/usr/bin/$$f; \
		fi \
	done
	$(NTP_FAKEROOT) rm -rf $(NTP_TARGET_DIR)/usr/share/ntp \
		$(TARGET_DIR)/usr/libexec \
		$(TARGET_DIR)/usr/lib
endef

define NTP_NTPD_SBIN_FIX
	$(NTP_FAKEROOT) mv $(NTP_TARGET_DIR)/usr/bin/ntpd $(NTP_TARGET_DIR)/usr/sbin
endef

define NTP_INSTALL_TARGET_CMDS
	$(NTP_FAKEROOT) $(MAKE) DESTDIR=$(NTP_TARGET_DIR) -C $(@D) install
	$(NTP_FAKEROOT) $(INSTALL) -D -m 644 package/ntp/ntpd.etc.conf $(NTP_TARGET_DIR)/etc/ntp.conf
endef

NTP_POST_INSTALL_TARGET_HOOKS += NTP_NTPD_SBIN_FIX
NTP_POST_INSTALL_TARGET_HOOKS += NTP_REMOVE_UNWANTED_FILES

ifeq ($(BR2_PACKAGE_NTP_NTPD),y)
define NTP_INSTALL_INIT_SYSV
	$(NTP_FAKEROOT) $(INSTALL) -D -m 755 package/ntp/ntpd.init $(NTP_TARGET_DIR)/etc/init.d/ntpd
	$(NTP_FAKEROOT) $(INSTALL) -D -m 644 package/ntp/ntpd.default $(NTP_TARGET_DIR)/etc/default/ntpd
endef

define NTP_INSTALL_INIT_SYSTEMD
	$(NTP_FAKEROOT) $(INSTALL) -D -m 644 package/ntp/ntpd.service $(NTP_TARGET_DIR)/etc/systemd/system/ntpd.service
	$(NTP_FAKEROOT) mkdir -p $(NTP_TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	$(NTP_FAKEROOT) ln -fs ../ntpd.service $(NTP_TARGET_DIR)/etc/systemd/system/multi-user.target.wants/ntpd.service
endef
endif

NTP_POST_PATCH_HOOKS += NTP_PATCH_FIXUPS

$(eval $(autotools-package))
