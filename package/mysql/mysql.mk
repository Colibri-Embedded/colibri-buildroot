################################################################################
#
# mysql
#
################################################################################

MYSQL_VERSION_MAJOR = 5.1
MYSQL_VERSION = $(MYSQL_VERSION_MAJOR).73
MYSQL_SOURCE = mysql-$(MYSQL_VERSION).tar.gz
MYSQL_SITE = http://downloads.skysql.com/archives/mysql-$(MYSQL_VERSION_MAJOR)
MYSQL_INSTALL_STAGING = YES
MYSQL_DEPENDENCIES = readline ncurses
MYSQL_AUTORECONF = YES
MYSQL_LICENSE = GPLv2
MYSQL_LICENSE_FILES = README COPYING

MYSQL_CONF_ENV = \
	ac_cv_sys_restartable_syscalls=yes \
	ac_cv_path_PS=/bin/ps \
	ac_cv_FIND_PROC="/bin/ps p \$\$PID | grep -v grep | grep mysqld > /dev/null" \
	ac_cv_have_decl_HAVE_IB_ATOMIC_PTHREAD_T_GCC=yes \
	ac_cv_have_decl_HAVE_IB_ATOMIC_PTHREAD_T_SOLARIS=no \
	ac_cv_have_decl_HAVE_IB_GCC_ATOMIC_BUILTINS=yes \
	mysql_cv_new_rl_interface=yes

MYSQL_CONF_OPTS = \
	--without-ndb-binlog \
	--without-docs \
	--without-man \
	--without-libedit \
	--without-readline \
	--with-low-memory \
	--enable-thread-safe-client \
	--disable-mysql-maintainer-mode

ifeq ($(BR2_PACKAGE_OPENSSL),y)
MYSQL_DEPENDENCIES += openssl
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
MYSQL_DEPENDENCIES += zlib
endif

ifeq ($(BR2_PACKAGE_MYSQL_SERVER),y)
MYSQL_DEPENDENCIES += host-mysql host-bison
HOST_MYSQL_DEPENDENCIES = host-zlib host-ncurses

HOST_MYSQL_CONF_OPTS = \
	--with-embedded-server \
	--disable-mysql-maintainer-mode

MYSQL_CONF_OPTS += \
	--localstatedir=/run \
	--with-unix-socket-path=/run/mysqld.sock \
	--with-atomic-ops=up \
	--without-query-cache


ifeq ($(BR2_PACKAGE_MYSQL_SERVER_PARTITION),y)
	BR2_PACKAGE_MYSQL_SERVER_PLUGINS += partition
else
	MYSQL_CONF_OPTS += --without-plugin-partition
endif

ifeq ($(BR2_PACKAGE_MYSQL_SERVER_ARCHIVE),y)
	BR2_PACKAGE_MYSQL_SERVER_PLUGINS += archive
else
	MYSQL_CONF_OPTS += --without-plugin-archive
endif

ifeq ($(BR2_PACKAGE_MYSQL_SERVER_BLACKHOLE),y)
	BR2_PACKAGE_MYSQL_SERVER_PLUGINS += blackhole
else
	MYSQL_CONF_OPTS += --without-plugin-blackhole
endif

ifeq ($(BR2_PACKAGE_MYSQL_SERVER_CSV),y)
	BR2_PACKAGE_MYSQL_SERVER_PLUGINS += csv
else
	MYSQL_CONF_OPTS += --without-plugin-partition
endif

ifeq ($(BR2_PACKAGE_MYSQL_SERVER_EXAMPLE),y)
	BR2_PACKAGE_MYSQL_SERVER_PLUGINS += example
else
	MYSQL_CONF_OPTS += --without-plugin-example
endif

ifeq ($(BR2_PACKAGE_MYSQL_SERVER_FEDERATED),y)
	BR2_PACKAGE_MYSQL_SERVER_PLUGINS += federated
else
	MYSQL_CONF_OPTS += --without-plugin-federated
endif

ifeq ($(BR2_PACKAGE_MYSQL_SERVER_INNOBASE_PLUGIN),y)
	BR2_PACKAGE_MYSQL_SERVER_PLUGINS += innodb_plugin
else
	MYSQL_CONF_OPTS += --without-plugin-innodb_plugin
endif

ifeq ($(BR2_PACKAGE_MYSQL_SERVER_NBDCLUSTER),y)
	BR2_PACKAGE_MYSQL_SERVER_PLUGINS += ndbcluster
else
	MYSQL_CONF_OPTS += --without-plugin-ndbcluster
endif

ifneq ($(BR2_PACKAGE_MYSQL_SERVER_PLUGINS),)
	BR2_PACKAGE_MYSQL_SERVER_PLUGINS_ARG = $(subst $(space),$(comma),$(BR2_PACKAGE_MYSQL_SERVER_PLUGINS))
	MYSQL_CONF_OPTS += --with-plugins-$(subst $(space),$(comma),$(BR2_PACKAGE_MYSQL_SERVER_PLUGINS))
endif

# Debugging is only available for the server, so no need for
# this if-block outside of the server if-block
ifeq ($(BR2_ENABLE_DEBUG),y)
MYSQL_CONF_OPTS += --with-debug=full
else
MYSQL_CONF_OPTS += --without-debug
endif

define HOST_MYSQL_BUILD_CMDS
	$(MAKE) -C $(@D)/include my_config.h
	$(MAKE) -C $(@D)/mysys libmysys.a
	$(MAKE) -C $(@D)/strings libmystrings.a
	$(MAKE) -C $(@D)/vio libvio.a
	$(MAKE) -C $(@D)/dbug libdbug.a
	$(MAKE) -C $(@D)/regex libregex.a
	$(MAKE) -C $(@D)/sql gen_lex_hash
endef

define HOST_MYSQL_INSTALL_CMDS
	$(INSTALL) -m 0755  $(@D)/sql/gen_lex_hash  $(HOST_DIR)/usr/bin/
endef

define MYSQL_USERS
	mysql -1 nogroup -1 * /var/mysql - - MySQL daemon
endef

define MYSQL_ADD_FOLDER
	$(INSTALL) -d $(MYSQL_TARGET_DIR)/var/mysql
endef

MYSQL_POST_INSTALL_TARGET_HOOKS += MYSQL_ADD_FOLDER

define MYSQL_INSTALL_INIT_SYSV
	$(MYSQL_FAKEROOT) $(MYSQL_FAKEROOT_ENV) $(INSTALL) -D -m 0755 package/mysql/mysqld.init \
		$(MYSQL_TARGET_DIR)/etc/init.d/mysqld
	$(MYSQL_FAKEROOT) $(MYSQL_FAKEROOT_ENV) $(INSTALL) -D -m 0755 package/mysql/mysqld.default \
		$(MYSQL_TARGET_DIR)/etc/default/mysqld
		
	$(MYSQL_FAKEROOT) $(MYSQL_FAKEROOT_ENV) $(INSTALL) -d -m 0755 $(MYSQL_TARGET_DIR)/etc/rc.d/rc.startup.d	
	$(MYSQL_FAKEROOT) $(MYSQL_FAKEROOT_ENV) $(INSTALL) -d -m 0755 $(MYSQL_TARGET_DIR)/etc/rc.d/rc.shutdown.d
	
	$(MYSQL_FAKEROOT) $(MYSQL_FAKEROOT_ENV) ln -fs ../../init.d/mysqld \
		$(MYSQL_TARGET_DIR)/etc/rc.d/rc.startup.d/S26mysqld
	$(MYSQL_FAKEROOT) $(MYSQL_FAKEROOT_ENV) ln -fs ../../init.d/mysqld \
		$(MYSQL_TARGET_DIR)/etc/rc.d/rc.shutdown.d/S26mysqld
endef

else
MYSQL_CONF_OPTS += \
	--without-server
endif


define MYSQL_REMOVE_TEST_PROGS
	rm -rf $(MYSQL_TARGET_DIR)/usr/mysql-test $(MYSQL_TARGET_DIR)/usr/sql-bench
endef

define MYSQL_ADD_MYSQL_LIB_PATH
	$(INSTALL) -d $(MYSQL_TARGET_DIR)/etc
	echo "/usr/lib/mysql" >> $(MYSQL_TARGET_DIR)/etc/ld.so.conf
endef

MYSQL_POST_INSTALL_TARGET_HOOKS += MYSQL_REMOVE_TEST_PROGS
MYSQL_POST_INSTALL_TARGET_HOOKS += MYSQL_ADD_MYSQL_LIB_PATH

$(eval $(autotools-package))
$(eval $(host-autotools-package))
