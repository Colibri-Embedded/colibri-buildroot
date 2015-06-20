################################################################################
#
# lighttpd
#
################################################################################

LIGHTTPD_VERSION_MAJOR = 1.4
LIGHTTPD_VERSION = $(LIGHTTPD_VERSION_MAJOR).35
LIGHTTPD_SOURCE = lighttpd-$(LIGHTTPD_VERSION).tar.xz
LIGHTTPD_SITE = http://download.lighttpd.net/lighttpd/releases-$(LIGHTTPD_VERSION_MAJOR).x
LIGHTTPD_LICENSE = BSD-3c
LIGHTTPD_LICENSE_FILES = COPYING
LIGHTTPD_DEPENDENCIES = host-pkgconf
LIGHTTPD_CONF_OPTS = \
	--libdir=/usr/lib/lighttpd \
	--libexecdir=/usr/lib \
	$(if $(BR2_LARGEFILE),,--disable-lfs)

LIGHTTPD_CONF_AVAILABLE_FILES = \
						01-mime.conf \
						10-accesslog.conf \
						10-dir-listing.conf \
						10-evhost.conf \
						10-fastcgi.conf \
						10-no-www.conf \
						10-rrdtool.conf \
						10-ssi.conf \
						10-status.conf \
						10-usertrack.conf \
						90-debian-doc.conf \
						05-auth.conf \
						10-cgi.conf \
						10-evasive.conf \
						10-expire.conf \
						10-flv-streaming.conf \
						10-proxy.conf \
						10-simple-vhost.conf \
						10-ssl.conf \
						10-userdir.conf \
						15-fastcgi-php.conf \
						README

ifeq ($(BR2_PACKAGE_LIGHTTPD_OPENSSL),y)
LIGHTTPD_DEPENDENCIES += openssl
LIGHTTPD_CONF_OPTS += --with-openssl
else
LIGHTTPD_CONF_OPTS += --without-openssl
endif

ifeq ($(BR2_PACKAGE_LIGHTTPD_ZLIB),y)
LIGHTTPD_DEPENDENCIES += zlib
LIGHTTPD_CONF_OPTS += --with-zlib
else
LIGHTTPD_CONF_OPTS += --without-zlib
endif

ifeq ($(BR2_PACKAGE_LIGHTTPD_BZIP2),y)
LIGHTTPD_DEPENDENCIES += bzip2
LIGHTTPD_CONF_OPTS += --with-bzip2
else
LIGHTTPD_CONF_OPTS += --without-bzip2
endif

ifeq ($(BR2_PACKAGE_LIGHTTPD_PCRE),y)
LIGHTTPD_CONF_ENV = PCRECONFIG=$(STAGING_DIR)/usr/bin/pcre-config
LIGHTTPD_DEPENDENCIES += pcre
LIGHTTPD_CONF_OPTS += --with-pcre
else
LIGHTTPD_CONF_OPTS += --without-pcre
endif

ifeq ($(BR2_PACKAGE_LIGHTTPD_WEBDAV),y)
LIGHTTPD_DEPENDENCIES += libxml2 sqlite
LIGHTTPD_CONF_OPTS += --with-webdav-props --with-webdav-locks
else
LIGHTTPD_CONF_OPTS += --without-webdav-props --without-webdav-locks
endif

ifeq ($(BR2_PACKAGE_LIGHTTPD_LUA),y)
LIGHTTPD_DEPENDENCIES += lua
LIGHTTPD_CONF_OPTS += --with-lua
else
LIGHTTPD_CONF_OPTS += --without-lua
endif

ifeq ($(BR2_PACKAGE_LIGHTTPD_IPV6),y)
LIGHTTPD_CONF_OPTS += --enable-ipv6
else
LIGHTTPD_CONF_OPTS += --disable-ipv6
endif

define LIGHTTPD_INSTALL_CONFIG
	$(LIGHTTPD_FAKEROOT) $(INSTALL) -d -m 0755 $(LIGHTTPD_TARGET_DIR)/etc/lighttpd/conf-available
	$(LIGHTTPD_FAKEROOT) $(INSTALL) -d -m 0755 $(LIGHTTPD_TARGET_DIR)/etc/lighttpd/conf-enabled
	$(LIGHTTPD_FAKEROOT) $(INSTALL) -d -o 33 -g 33 -m 0755 $(LIGHTTPD_TARGET_DIR)/var/www
	$(LIGHTTPD_FAKEROOT) $(INSTALL) -d -o 33 -g 33 -m 0755 $(LIGHTTPD_TARGET_DIR)/var/cache/lighttpd
	$(LIGHTTPD_FAKEROOT) $(INSTALL) -d -o 33 -g 33 -m 0755 $(LIGHTTPD_TARGET_DIR)/var/log/lighttpd

	$(LIGHTTPD_FAKEROOT) chown 33.33 $(LIGHTTPD_TARGET_DIR)/var/www
	$(LIGHTTPD_FAKEROOT) chown 33.33 $(LIGHTTPD_TARGET_DIR)/var/cache/lighttpd
	$(LIGHTTPD_FAKEROOT) chown 33.33 $(LIGHTTPD_TARGET_DIR)/var/log/lighttpd

	$(LIGHTTPD_FAKEROOT) $(INSTALL) -D -m 0644 package/lighttpd/lighttpd.conf \
		$(LIGHTTPD_TARGET_DIR)/etc/lighttpd/lighttpd.conf
		
	$(LIGHTTPD_FAKEROOT) $(INSTALL) -D -m 0755 package/lighttpd/include-conf-enabled.sh \
		$(LIGHTTPD_TARGET_DIR)/usr/share/lighttpd/include-conf-enabled.sh
		
	$(LIGHTTPD_FAKEROOT) $(INSTALL) -D -m 0755 package/lighttpd/lighttpd-enable-mod \
		$(LIGHTTPD_TARGET_DIR)/usr/sbin/lighttpd-enable-mod

	$(LIGHTTPD_FAKEROOT) ln -fs lighttpd-enable-mod \
		$(LIGHTTPD_TARGET_DIR)/usr/sbin/lighttpd-disable-mod
		
for conf in $(LIGHTTPD_CONF_AVAILABLE_FILES); do \
	$(LIGHTTPD_FAKEROOT) $(INSTALL) -D -m 0644 package/lighttpd/conf-available/$$conf \
		$(LIGHTTPD_TARGET_DIR)/etc/lighttpd/conf-available/$$conf; \
done

	$(LIGHTTPD_FAKEROOT) ln -fs ../conf-available/01-mime.conf \
		$(LIGHTTPD_TARGET_DIR)/etc/lighttpd/conf-enabled/01-mime.conf

	$(LIGHTTPD_FAKEROOT) ln -fs ../conf-available/10-accesslog.conf \
		$(LIGHTTPD_TARGET_DIR)/etc/lighttpd/conf-enabled/01-accesslog.conf
		
endef

LIGHTTPD_POST_INSTALL_TARGET_HOOKS += LIGHTTPD_INSTALL_CONFIG

define LIGHTTPD_INSTALL_INIT_SYSV
	$(LIGHTTPD_FAKEROOT) $(LIGHTTPD_FAKEROOT_ENV) $(INSTALL) -D -m 0755 package/lighttpd/lighttpd.init \
		$(LIGHTTPD_TARGET_DIR)/etc/init.d/lighttpd
	$(LIGHTTPD_FAKEROOT) $(LIGHTTPD_FAKEROOT_ENV) $(INSTALL) -D -m 0755 package/lighttpd/lighttpd.default \
		$(LIGHTTPD_TARGET_DIR)/etc/default/lighttpd
		
	$(LIGHTTPD_FAKEROOT) $(LIGHTTPD_FAKEROOT_ENV) $(INSTALL) -d -m 0755 $(LIGHTTPD_TARGET_DIR)/etc/rc.d/rc.startup.d	
	$(LIGHTTPD_FAKEROOT) $(LIGHTTPD_FAKEROOT_ENV) $(INSTALL) -d -m 0755 $(LIGHTTPD_TARGET_DIR)/etc/rc.d/rc.shutdown.d
	
	$(LIGHTTPD_FAKEROOT) $(LIGHTTPD_FAKEROOT_ENV) ln -fs ../../init.d/lighttpd \
		$(LIGHTTPD_TARGET_DIR)/etc/rc.d/rc.startup.d/S28lighttpd
	$(LIGHTTPD_FAKEROOT) $(LIGHTTPD_FAKEROOT_ENV) ln -fs ../../init.d/lighttpd \
		$(LIGHTTPD_TARGET_DIR)/etc/rc.d/rc.shutdown.d/S28lighttpd
endef

define LIGHTTPD_INSTALL_INIT_SYSTEMD
	$(LIGHTTPD_FAKEROOT) $(LIGHTTPD_FAKEROOT_ENV) $(INSTALL) -D -m 0644 package/lighttpd/lighttpd.service \
		$(LIGHTTPD_TARGET_DIR)/etc/systemd/system/lighttpd.service

	$(LIGHTTPD_FAKEROOT) $(LIGHTTPD_FAKEROOT_ENV) mkdir -p $(LIGHTTPD_TARGET_DIR)/etc/systemd/system/multi-user.target.wants

	$(LIGHTTPD_FAKEROOT) $(LIGHTTPD_FAKEROOT_ENV) ln -fs ../lighttpd.service \
		$(LIGHTTPD_TARGET_DIR)/etc/systemd/system/multi-user.target.wants/lighttpd.service
endef

$(eval $(autotools-package))
